module Doi
  # Doi::DoiResolverContext
  #
  # This class provides the context for resolving a DOI. It stores the DOI and the URL
  # used for resolution, and makes these available to resolvers during the resolution process.
  # The `DoiResolverContext` is passed between resolvers to ensure that they have the necessary
  # information to resolve the DOI correctly.
  #
  # Attributes:
  # - `doi`: The DOI (Digital Object Identifier) to be resolved.
  # - `doi_url`: The URL constructed from the DOI or provided for resolution.
  class DoiResolverContext
    attr_reader :doi, :object_url, :http_client
    attr_accessor :type, :datacite_response

    def initialize(doi, object_url, http_client: Common::HttpClient.new)
      @doi = doi
      @object_url = object_url
      @http_client = http_client
    end

    def result
      { doi: doi, object_url: object_url, type: type } if type
    end
  end
end

