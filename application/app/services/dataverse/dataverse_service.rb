module Dataverse
  class DataverseService
    include LoggingCommon
    include DateTimeCommon

    class UnauthorizedException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url))
      @dataverse_url = dataverse_url
      @http_client = http_client
    end

    def find_dataset_by_persistent_id(persistent_id)
      url = "/api/datasets/:persistentId/?persistentId=#{persistent_id}&returnOwners=true"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset: #{response.code} - #{response.body}" unless response.success?
      DatasetResponse.new(response.body)
    end

    def find_dataverse_by_id(id)
      url = "/api/dataverses/#{id}?returnOwners=true"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse: #{response.code} - #{response.body}" unless response.success?
      DataverseResponse.new(response.body)
    end

    def search_dataverse_items(dataverse_id, page = 1, per_page = 10)
      start = (page-1) * per_page
      query_string = "q=*&show_facets=true&sort=date&order=desc&show_type_counts=true&per_page=#{per_page}&start=#{start}&type=dataverse&type=dataset&subtree=#{dataverse_id}"
      url = "/api/search?#{query_string}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse items: #{response.code} - #{response.body}" unless response.success?
      SearchResponse.new(response.body, page, per_page)
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
          f.creation_date = now
          f.type = ConnectorType::DATAVERSE
          f.filename = dataset_file.data_file.filename
          f.status = FileStatus::READY
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