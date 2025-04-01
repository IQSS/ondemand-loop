# frozen_string_literal: true
module Dataverse
  # Dataverse connector download processor. Responsible for downloading files of type Dataverse
  class ConnectorDownloadProcessor
    include LoggingCommon

    def download(download_file)
      collection = DownloadCollection.find(download_file.collection_id)
      dataverse_metadata = Dataverse::DataverseMetadata.find(collection.metadata_id)
      download_url = "#{dataverse_metadata.full_hostname}/api/access/datafile/#{download_file.external_id}"
      download_location = File.join(collection.download_dir, download_file.filename)
      temp_location ="#{download_location}.part"

      download_file.connector_metadata[:download_url] = download_url
      download_file.connector_metadata[:download_location] = download_location
      download_file.connector_metadata[:temp_location] = temp_location
      download_file.save

      download_processor = Download::BasicHttpRubyDownload.new(download_url, download_location, temp_location)
      download_processor.download
      verification_result = verify(download_location, download_file.checksum)
      log_info('Download completed', {id: download_file.id, location: download_location, verification: verification_result})
    end

    private
    def verify(file_path, expected_md5)
      return false unless File.exist?(file_path)

      file_md5 = Digest::MD5.file(file_path).hexdigest
      file_md5 == expected_md5
    end
  end
end