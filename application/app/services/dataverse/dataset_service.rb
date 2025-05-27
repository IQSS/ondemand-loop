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
      url = "/api/dataverses/#{dataverse_id}/datasets"
      response = @http_client.post(url, body: dataset_data.to_body, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error creating dataset: #{response.status} - #{response.body}" unless response.success?
      CreateDatasetResponse.new(response.body)
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
  end
end