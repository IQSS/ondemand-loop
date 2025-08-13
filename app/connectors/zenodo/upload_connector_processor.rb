# frozen_string_literal: true

module Zenodo
  class UploadConnectorProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled
    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
      @cancelled = false
      Command::CommandRegistry.instance.register('upload.cancel', self)
      Command::CommandRegistry.instance.register('upload.status', self)
    end

    def upload
      bucket_url = connector_metadata.bucket_url
      return response(FileStatus::ERROR, 'Missing bucket URL in connector metadata') unless bucket_url

      # Step 2: Prepare file upload
      source_location = file.file_location
      file_name = File.basename(file.filename)
      upload_url = FluentUrl.new(bucket_url).add_path(file_name).to_s

      connector_metadata.upload_url = upload_url
      file.upload_bundle.update({ metadata: connector_metadata.to_h })

      headers = { Zenodo::ApiService::AUTH_HEADER => "Bearer #{connector_metadata.api_key.value}" }
      upload_processor = Zenodo::ZenodoBucketHttpUploader.new(upload_url, source_location, headers)
      upload_processor.upload do |context|
        @status_context = context
        cancelled
      end

      return response(FileStatus::CANCELLED, 'file upload cancelled') if cancelled

      response(FileStatus::SUCCESS, 'file upload completed')
    end

    def process(request)
      if request.command == 'upload.cancel'
        if file.id == request.body.file_id
          # CANCELLATION IS FOR THIS FILE
          @cancelled = true
          return { message: 'cancellation requested' }
        end
      end

      if request.command == 'upload.status'
        if file.id == request.body.file_id
          return { message: 'upload in progress', status: @status_context }
        end
      end

      return nil # rubocop:disable Style/RedundantReturn
    end

    private

    def response(status, message)
      OpenStruct.new({ status: status, message: message })
    end
  end
end
