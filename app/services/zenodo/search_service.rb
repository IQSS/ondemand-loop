module Zenodo
  class SearchService
    def initialize(zenodo_url = 'https://zenodo.org', http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def search(query, page: 1, per_page: 10)
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('records')
              .add_param('page', page)
              .add_param('q', query)
              .add_param('size', per_page)
              .to_s
      response = @http_client.get(url)
      return nil unless response.success?
      SearchResponse.new(response.body, page, per_page)
    end
  end
end
