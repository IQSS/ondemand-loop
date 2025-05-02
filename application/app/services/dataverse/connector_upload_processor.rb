# frozen_string_literal: true
module Dataverse
  # Dataverse connector download processor. Responsible for downloading files of type Dataverse
  class ConnectorUploadProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled
    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
      @cancelled = false
      #Upload::Command::UploadCommandRegistry.instance.register('cancel', self)
    end

    def upload
      project = Project.find(file.project_id)
      upload_url = "#{connector_metadata.dataverse_url}/api/datasets/:persistentId/add?persistentId=#{connector_metadata.id}"
      source_location = File.join(project.download_dir, connector_metadata.filename)
      temp_location ="#{source_location}.part"

      connector_metadata.upload_url = upload_url
      connector_metadata.source_location = source_location
      connector_metadata.temp_location = temp_location
      file.update({metadata: connector_metadata.to_h})

      upload_processor = Upload::BasicHttpRubyUploader.new(upload_url, source_location, temp_location)
      upload_processor.upload do |context|
        cancelled
      end

      if cancelled
        return response(FileStatus::CANCELLED, 'file upload cancelled')
      end

      #TODO verify md5 checksum in the server once the file is uploaded

      response(FileStatus::SUCCESS, 'file upload completed')
    end

    def process(request)
      if file.id == request.body.file_id
        # CANCELLATION IS FOR THIS FILE
        @cancelled = true
        return {message: 'cancellation requested'}
      end

      return nil
    end

    private

    def response(file_status, message)
      OpenStruct.new({status: file_status, message: message})
    end
  end
end