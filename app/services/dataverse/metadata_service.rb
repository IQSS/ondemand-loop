module Dataverse
  class MetadataService < Dataverse::ApiService

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key: nil)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @api_key = api_key
    end

    def get_citation_metadata
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('metadatablocks')
              .add_path('citation')
              .to_s
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting dataverse citation metadata: #{response.status} - #{response.body}" unless response.success?
      CitationMetadataResponse.new(response.body)
    end
  end
end