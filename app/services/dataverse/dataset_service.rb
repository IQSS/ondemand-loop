module Dataverse
  class DatasetService < Dataverse::ApiService

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key: nil)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @api_key = api_key
    end

    def create_dataset(dataverse_id, dataset_data)
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('dataverses')
              .add_path(dataverse_id)
              .add_path('datasets')
              .to_s
      response = @http_client.post(url, body: dataset_data.to_body, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error creating dataset: #{response.status} - #{response.body}" unless response.success?
      CreateDatasetResponse.new(response.body)
    end

    def find_dataset_version_by_persistent_id(persistent_id, version: ':latest-published')
      version = ':latest-published' if version.to_s.strip.empty?
      headers = {}
      headers[AUTH_HEADER] = @api_key if @api_key && version != ':latest-published'
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('datasets')
              .add_path(':persistentId')
              .add_path('versions')
              .add_path(version)
              .add_param('persistentId', persistent_id)
              .add_param('returnOwners', true)
              .add_param('excludeFiles', true)
              .to_s
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset: #{response.status} - #{response.body}" unless response.success?
      DatasetVersionResponse.new(response.body)
    end

    def search_dataset_files_by_persistent_id(persistent_id, version: ':latest-published', page: 1, per_page: nil, query: nil)
      version = ':latest-published' if version.to_s.strip.empty?
      per_page ||= Configuration.default_pagination_items
      headers = {}
      headers[AUTH_HEADER] = @api_key if @api_key
      url = SearchDatasetFilesUrlBuilder.new(
        persistent_id: persistent_id,
        version: version,
        page: page,
        per_page: per_page,
        query: query,
      ).build
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset files: #{response.status} - #{response.body}" unless response.success?
      DatasetFilesResponse.new(response.body, page: page, per_page: per_page, query: query)
    end

    def dataset_versions_by_persistent_id(persistent_id)
      headers = {}
      headers[AUTH_HEADER] = @api_key if @api_key
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('datasets')
              .add_path(':persistentId')
              .add_path('versions')
              .add_param('persistentId', persistent_id)
              .add_param('excludeFiles', true)
              .add_param('excludeMetadataBlocks', true)
              .to_s
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataset versions: #{response.status} - #{response.body}" unless response.success?
      DatasetVersionsResponse.new(response.body)
    end
  end
end
