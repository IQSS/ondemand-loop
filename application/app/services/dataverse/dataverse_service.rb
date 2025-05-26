module Dataverse
  class DataverseService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'X-Dataverse-key'
    class UnauthorizedException < Exception; end
    class ApiKeyRequiredException < Exception; end

    def initialize(dataverse_url, api_key: nil, http_client: Common::HttpClient.new(base_url: dataverse_url), file_utils: Common::FileUtils.new)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @file_utils = file_utils
      @api_key = api_key
    end

    def get_citation_metadata
      url = "/api/metadatablocks/citation"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse citation metadata: #{response.status} - #{response.body}" unless response.success?
      CitationMetadataResponse.new(response.body)
    end

    def get_my_collections(page: 1, per_page: 100)
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      start = (page-1) * per_page
      url = "/api/mydata/retrieve?role_ids=1&role_ids=3&role_ids=5&role_ids=7&dvobject_types=Dataverse&start=#{start}&per_page=#{per_page}&published_states=Published&published_states=Unpublished"
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting my dataverse data: #{response.status} - #{response.body}" unless response.success?
      MyDataverseCollectionsResponse.new(response.body, page: page, per_page: per_page)
    end

    def find_dataset_version_by_persistent_id(persistent_id, version: ':latest-published')
      url = "/api/datasets/:persistentId/versions/#{version}?persistentId=#{persistent_id}&returnOwners=true&excludeFiles=true"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset: #{response.status} - #{response.body}" unless response.success?
      DatasetVersionResponse.new(response.body)
    end

    def search_dataset_files_by_persistent_id(persistent_id, version: ':latest-published', page: 1, per_page: 10)
      start = (page-1) * per_page
      url = "/api/datasets/:persistentId/versions/#{version}/files?persistentId=#{persistent_id}&offset=#{start}&limit=#{per_page}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset files: #{response.status} - #{response.body}" unless response.success?
      DatasetFilesResponse.new(response.body, page: page, per_page: per_page)
    end

    def find_dataverse_by_id(id)
      url = "/api/dataverses/#{id}?returnOwners=true"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse: #{response.status} - #{response.body}" unless response.success?
      DataverseResponse.new(response.body)
    end

    def search_dataverse_items(dataverse_id, page = 1, per_page = 10, include_collections = true, include_datasets = true)
      start = (page-1) * per_page
      type_collection = include_collections ? "&type=dataverse" : ""
      type_dataset = include_datasets ? "&type=dataset" : ""
      query_string = "q=*&show_facets=true&sort=date&order=desc&show_type_counts=true&per_page=#{per_page}&start=#{start}#{type_collection}#{type_dataset}&subtree=#{dataverse_id}"
      url = "/api/search?#{query_string}"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse items: #{response.status} - #{response.body}" unless response.success?
      SearchResponse.new(response.body, page, per_page)
    end

    def initialize_project(dataset)
      name = ProjectNameGenerator.generate
      Project.new(id: name, name: name)
    end

    def initialize_download_files(project, dataset, files_page, file_ids)
      dataset_files = files_page.files_by_ids(file_ids)
      dataset_files.each.map do |dataset_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::DATAVERSE
          f.filename = dataset_file.full_filename
          f.status = FileStatus::PENDING
          f.size = dataset_file.filesize
          f.metadata = {
            dataverse_url: @dataverse_url,
            persistent_id: dataset.data.dataset_persistent_id,
            parents: dataset.data.parents,
            id: dataset_file.data_file.id.to_s,
            content_type: dataset_file.content_type,
            storage: dataset_file.data_file.storage_identifier,
            md5: dataset_file.data_file.md5,
            download_url: nil,
            download_location: nil,
            temp_location: nil,
          }

          @file_utils.make_download_file_unique(f)
        end
      end
    end

  end
end