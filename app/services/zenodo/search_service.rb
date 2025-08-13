module Zenodo
  class SearchService
    def initialize(zenodo_url = Zenodo::ZenodoUrl::DEFAULT_URL, http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def search(query, page: 1, per_page: nil)
      per_page ||= Configuration.default_pagination_items
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
