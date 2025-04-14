# frozen_string_literal: true
module Doi
  class DoiService
    include LoggingCommon

    def initialize(api_url: 'https://doi.org', http_client: nil)
      @api_url = api_url
      @http_client = http_client || Common::HttpClient.new
    end

    def resolve(doi)
      doi_url = URI.parse(File.join(@api_url, doi))
      response = @http_client.head(doi_url.to_s)
      if response.redirect?
        object_url = response.location
        log_info('DOI resolved', {doi_url: doi_url, object_url: object_url})
        object_url
      else
        log_info('Unable to resolve DOI', {doi_url: doi_url, response: response.status})
        nil
      end

    end
  end
end
