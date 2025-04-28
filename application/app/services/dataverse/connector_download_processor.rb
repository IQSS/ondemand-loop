# frozen_string_literal: true
module Dataverse
  # Dataverse connector download processor. Responsible for downloading files of type Dataverse
  class ConnectorDownloadProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled
    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
      @cancelled = false
      Download::Command::DownloadCommandRegistry.instance.register('cancel', self)
    end

    def download
      collection = DownloadCollection.find(file.collection_id)
      download_url = "#{connector_metadata.dataverse_url}/api/access/datafile/#{connector_metadata.id}"
      download_location = File.join(collection.download_dir, connector_metadata.filename)
      temp_location ="#{download_location}.part"

      connector_metadata.download_url = download_url
      connector_metadata.download_location = download_location
      connector_metadata.temp_location = temp_location
      file.metadata = connector_metadata.to_h
      file.save

      download_processor = Download::BasicHttpRubyDownloader.new(download_url, download_location, temp_location)
      download_processor.download do |context|
        cancelled
      end

      if cancelled
        return response(FileStatus::CANCELLED, 'file download cancelled')
      end

      md5_result = verify(download_location,  connector_metadata.md5)
      log_info('Download completed', {id: file.id, location: download_location, md5_valid: md5_result})
      if md5_result
        response(FileStatus::SUCCESS, 'file download completed')
      else
        response(FileStatus::ERROR, 'file download completed, md5 check failed')
      end
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

    def verify(file_path, expected_md5)
      return false unless File.exist?(file_path)

      file_md5 = Digest::MD5.file(file_path).hexdigest
      file_md5 == expected_md5
    end

    def response(file_status, message)
      OpenStruct.new({status: file_status, message: message})
    end
  end
end