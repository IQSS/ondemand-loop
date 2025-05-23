module Dataverse
  class DatasetService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'X-Dataverse-key'
    class UnauthorizedException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key:, file_utils: Common::FileUtils.new)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @file_utils = file_utils
      @api_key = api_key
    end

    def create_dataset(dataverse_id, body, api_key: @api_key)
      url = "/api/dataverses/#{dataverse_id}/datasets"
      response = @http_client.post(url, body: body.to_json, headers: { AUTH_HEADER => api_key })
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error creating dataset: #{response.status} - #{response.body}" unless response.success?
      CreateDatasetResponse.new(response.body)
    end
  end
end