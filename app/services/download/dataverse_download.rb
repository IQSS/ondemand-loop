# frozen_string_literal: true
module Download
  # Dataverse connector download service. Responsible of downloading files of type Dataverse
  class DataverseDownload

    def download(download_file)
      collection = DownloadCollection.find(download_file.collection_id)
      dataverse_metadata = Dataverse::DataverseMetadata.find(collection.metadata_id)
      download_url = "#{dataverse_metadata.full_hostname}/api/access/datafile/#{download_file.external_id}"
      download_location = File.join(collection.download_dir, download_file.filename)
      download_processor = Download::BasicHttpRubyDownload.new(download_url, download_location)
      download_processor.download
    end
  end
end