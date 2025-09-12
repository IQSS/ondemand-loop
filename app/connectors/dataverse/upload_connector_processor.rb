# frozen_string_literal: true

module Dataverse
  # Dataverse upload connector processor. Responsible for uploading files of type Dataverse
  class UploadConnectorProcessor
    include LoggingCommon
    include EventLogger

    attr_reader :file, :connector_metadata, :cancelled, :status_context
    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
      @cancelled = false
      @status_context = nil
      Command::CommandRegistry.instance.register('upload.cancel', self)
      Command::CommandRegistry.instance.register('upload.status', self)
    end

    def upload
      upload_url = FluentUrl.new(connector_metadata.dataverse_url)
                             .add_path('api')
                             .add_path('datasets')
                             .add_path(':persistentId')
                             .add_path('add')
                             .add_param(:persistentId, connector_metadata.dataset_id)
                             .to_s
      source_location = file.file_location
      headers = { "X-Dataverse-key" => connector_metadata.api_key&.value }
      payload = {
        "description" => I18n.t('connectors.dataverse.upload_connector_processor.upload_payload_description'),
        "directoryLabel" => File.dirname(file.filename)
      }

      connector_metadata.upload_url = upload_url
      file.upload_bundle.update({ metadata: connector_metadata.to_h})

      upload_processor = Upload::MultipartHttpRubyUploader.new(upload_url, source_location, payload, headers)
      response_body = upload_processor.upload do |context|
        @status_context = context
        cancelled
      end

      if cancelled
        return response(FileStatus::CANCELLED, 'file upload cancelled')
      end

      success = true
      if response_body
        upload_response = Dataverse::UploadFileResponse.new(response_body)
        if Common::FileUtils.new.zip_file?(source_location)
          log_info('Zip file detected. Skipping MD5 check', {filename: file.filename})
        else
          server_md5 = upload_response.data.files.first&.data_file&.md5
          success = verify(source_location, server_md5)
        end
      end

      log_info('Upload completed', {id: file.id, success: success})

      if success
        response(FileStatus::SUCCESS, 'file upload completed')
      else
        response(FileStatus::ERROR, 'file upload completed, md5 check failed')
      end
    end

    def process(request)
      if request.command == 'upload.cancel'
        if file.id == request.body.file_id
          # CANCELLATION IS FOR THIS FILE
          @cancelled = true
          return {message: 'cancellation requested'}
        end
      end

      if request.command == 'upload.status'
        if file.id == request.body.file_id
          return {message: 'upload in progress', status: @status_context}
        end
      end

      return nil
    end

    private

    def verify(file_path, expected_md5)
      return true unless expected_md5

      file_md5 = Digest::MD5.file(file_path).hexdigest
      if file_md5 == expected_md5
        log_info('Checksum verification success', {file_path: file_path, expected_md5: expected_md5})
        true
      else
        log_error('Checksum verification failed', {file_path: file_path, expected_md5: expected_md5, current_md5: file_md5})
        log_upload_file_event(file, message: 'events.upload_file.error_checksum_verification', metadata: {
          error: I18n.t('events.upload_file.error_checksum_verification_message'),
          file_path: file_path,
          expected_md5: expected_md5,
          current_md5: file_md5
        })
        false
      end
    end

    def response(file_status, message)
      OpenStruct.new({status: file_status, message: message})
    end
  end
end