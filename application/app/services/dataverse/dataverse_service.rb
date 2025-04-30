module Dataverse
  class DataverseService
    include LoggingCommon
    include DateTimeCommon

    class UnauthorizedException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url))
      @dataverse_url = dataverse_url
      @http_client = http_client
    end

    def find_dataset_version_by_persistent_id(persistent_id, version: ':latest-published')
      url = "/api/datasets/:persistentId/versions/#{version}?persistentId=#{persistent_id}&returnOwners=true&excludeFiles=true"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset: #{response.code} - #{response.body}" unless response.success?
      DatasetVersionResponse.new(response.body)
    end

    def search_dataset_files_by_persistent_id(persistent_id, version: ':latest-published', page: 1, per_page: 10)
      start = (page-1) * per_page
      url = "/api/datasets/:persistentId/versions/#{version}/files?persistentId=#{persistent_id}&offset=#{start}&limit=#{per_page}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset files: #{response.code} - #{response.body}" unless response.success?
      DatasetFilesResponse.new(response.body, page: page, per_page: per_page)
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
      DownloadCollection.new(name: "#{@dataverse_url} Dataverse selection from #{dataset.data.dataset_persistent_id}")
    end

    def initialize_download_files(download_collection, files_page, file_ids)
      dataset_files = files_page.files_by_ids(file_ids)
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