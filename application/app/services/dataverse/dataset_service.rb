module Dataverse
  class DatasetService
    include LoggingCommon
    include DateTimeCommon

    class UnauthorizedException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), file_utils: Common::FileUtils.new)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @file_utils = file_utils
    end

    def get_citation_metadata
      url = "/api/metadatablocks/citation"
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse subjects: #{response.status} - #{response.body}" unless response.success?
      CitationMetadataResponse.new(response.body)
    end
  end
end