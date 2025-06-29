# frozen_string_literal: true

module Zenodo
  class DownloadConnectorProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled

    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
      @cancelled = false
      Command::CommandRegistry.instance.register('download.cancel', self)
    end

    def download
      project = Project.find(file.project_id)
      download_url = connector_metadata.download_url
      download_location = File.join(project.download_dir, file.filename)
      temp_location = "#{download_location}.part"
      FileUtils.mkdir_p(File.dirname(download_location))

      connector_metadata.download_location = download_location
      connector_metadata.temp_location = temp_location
      file.update({metadata: connector_metadata.to_h})

      download_processor = Download::BasicHttpRubyDownloader.new(download_url, download_location, temp_location)
      download_processor.download do |_context|
        cancelled
      end

      return response(FileStatus::CANCELLED, 'file download cancelled') if cancelled

      response(FileStatus::SUCCESS, 'file download completed')
    end

    def process(request)
      if file.id == request.body.file_id
        @cancelled = true
        return { message: 'cancellation requested' }
      end
      nil
    end

    private

    def response(file_status, message)
      OpenStruct.new({ status: file_status, message: message })
    end
  end
end
