module Dataverse
  class CollectionService < Dataverse::ApiService

    def initialize(dataverse_url, api_key: nil, http_client: Common::HttpClient.new(base_url: dataverse_url))
      @dataverse_url = dataverse_url
      @http_client = http_client
      @api_key = api_key
    end

    def get_my_collections(page: 1, per_page: 100)
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      start = (page - 1) * per_page
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('mydata')
              .add_path('retrieve')
              .add_param('role_ids', [1, 3, 5, 7])
              .add_param('dvobject_types', 'Dataverse')
              .add_param('start', start)
              .add_param('per_page', per_page)
              .add_param('published_states', ['Published', 'Unpublished'])
              .to_s
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting my collection data: #{response.status} - #{response.body}" unless response.success?
      MyDataverseCollectionsResponse.new(response.body, page: page, per_page: per_page)
    end

    def find_collection_by_id(id)
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('dataverses')
              .add_path(id)
              .add_param('returnOwners', true)
              .to_s
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting collection: #{response.status} - #{response.body}" unless response.success?
      CollectionResponse.new(response.body)
    end

    def search_collection_items(collection_id, page: 1, per_page: 10, include_collections: true, include_datasets: true, query: nil)
      url = SearchCollectionItemsUrlBuilder.new(
        collection_id: collection_id,
        page: page,
        per_page: per_page,
        include_collections: include_collections,
        include_datasets: include_datasets,
        query: query
      ).build
      response = @http_client.get(url)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting collection items: #{response.status} - #{response.body}" unless response.success?
      SearchResponse.new(response.body, page, per_page)
    end
  end
end