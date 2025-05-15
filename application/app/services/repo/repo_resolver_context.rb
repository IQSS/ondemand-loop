module Repo
  class RepoResolverContext
    attr_reader :input, :parsed_input, :http_client
    attr_accessor :doi, :object_url, :type, :datacite_response

    def initialize(input, http_client: Common::HttpClient.new)
      @input = input
      @parsed_input = Repo::RepoUrlParser.parse(input)
      @http_client = http_client
    end

    def result
      { doi: doi, object_url: object_url, type: type } if type
    end
  end
end

