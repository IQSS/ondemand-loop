module Dataverse
  class DataverseService

    def initialize(dataverse_url)
      @dataverse_url = dataverse_url
    end

    def find_dataset_by_id(id)
      url = @dataverse_url + "/api/datasets/#{id}"
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)
      response.is_a?(Net::HTTPSuccess) ? DatasetResponse.new(response.body) : nil
    end

    def find_dataset_by_persistent_id(persistent_id)
      url = @dataverse_url + "/api/datasets/:persistentId/?persistentId=#{persistent_id}"
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)
      response.is_a?(Net::HTTPSuccess) ? DatasetResponse.new(response.body) : nil
    end

    def initialize_download_collection(dataset)
      DownloadCollection.new(name: "#{@dataverse_url} Dataverse selection from #{dataset.data.identifier}")
    end

    def initialize_download_files(download_collection, dataset, file_ids)
      dataset_files = dataset.files_by_ids(file_ids)
      dataset_files.each.map do |dataset_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.collection_id = download_collection.id
          f.type = 'dataverse'
          f.filename = dataset_file.data_file.filename
          f.status = 'ready'
          f.size = dataset_file.data_file.filesize
          f.metadata = {
            dataverse_url: @dataverse_url,
            id: dataset_file.data_file.id.to_s,
            filename: dataset_file.data_file.filename,
            size: dataset_file.data_file.filesize,
            content_type: dataset_file.data_file.content_type,
            storage: dataset_file.data_file.storage_identifier,
            md5: dataset_file.data_file.md5,
            download_url: nil,
            download_location: nil,
            temp_location: nil,
          }
        end
      end
    end
  end
end