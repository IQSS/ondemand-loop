module Zenodo
  class SearchService
    def initialize(zenodo_url = 'https://zenodo.org', http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def search(query, page: 1, per_page: 10)
      params = { q: query, page: page, size: per_page }
      response = @http_client.get('/api/records', params: params)
      return nil unless response.success?
      SearchResponse.new(response.body, page, per_page)
    end
  end
end
