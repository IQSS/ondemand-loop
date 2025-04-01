module Dataverse
  class DataverseService

    def initialize(dataverse_metadata)
      @dataverse_metadata = dataverse_metadata
    end

    def find_dataset_by_id(id)
      url = @dataverse_metadata.full_hostname + "/api/datasets/#{id}"
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)
      response.is_a?(Net::HTTPSuccess) ? DatasetResponse.new(response.body) : nil
    end

    def initialize_download_collection(dataset)
      DownloadCollection.new.tap do |collection|
        collection.id = DownloadCollection.generate_id
        collection.type = "dataverse"
        collection.metadata_id = @dataverse_metadata.id
        collection.name = "#{@dataverse_metadata.full_hostname} Dataverse selection from #{dataset.data.identifier}"
      end
    end

    def initialize_download_files(download_collection, dataset, file_ids)
      dataset_files = dataset.files_by_ids(file_ids)
      dataset_files.each.map do |dataset_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.collection_id = download_collection.id
          f.type = 'dataverse'
          f.metadata_id = download_collection.metadata_id
          f.external_id = dataset_file.data_file.id
          f.filename = dataset_file.data_file.filename
          f.status = 'ready'
          f.size = dataset_file.data_file.filesize
          f.checksum = dataset_file.data_file.md5
          f.content_type = dataset_file.data_file.content_type
          f.connector_metadata = {
            dataverse_metadata: dataset_file.metadata_id,
            id: dataset_file.data_file.id,
            filename: dataset_file.data_file.filename,
            size: dataset_file.data_file.filesize,
            content_type: dataset_file.data_file.content_type,
            storage: dataset_file.storage_identifier,
            md5: dataset_file.data_file.md5,
          }
        end
      end
    end
  end
end