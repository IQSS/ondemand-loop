require 'test_helper'

class Dataverse::CollectionServiceTest < ActiveSupport::TestCase
  include DataverseHelper

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/collection_response/valid_response.json'))
    @service = Dataverse::CollectionService.new('https://example.com', http_client: @client)
  end

  test 'find_collection_by_id returns parsed response' do
    collection = @service.find_collection_by_id('123')
    assert_kind_of Dataverse::CollectionResponse, collection
    assert_equal 1234, collection.data.id
    assert_equal 'Sample Dataverse', collection.data.name
    assert_equal 'Dataverse_Alias', collection.data.alias
  end

  test 'search_collection_items parses items and supports paging' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/search_response/valid_response.json'))
    @service = Dataverse::CollectionService.new('https://example.com', http_client: @client)
    res = @service.search_collection_items('dv', page: 1, per_page: 10)
    assert_kind_of Dataverse::SearchResponse, res
    assert_operator res.data.items.count, :>, 0
    assert_equal 195882, res.data.total_count
  end

  test 'search_collection_items builds url with all parameters' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/search_response/valid_response.json'))
    @service = Dataverse::CollectionService.new('https://example.com', http_client: @client)
    @service.search_collection_items('dv', page: 2, per_page: 5, include_collections: false, include_datasets: true, query: 'term')
    expected = '/api/search?order=desc&per_page=5&q=term&show_facets=true&sort=date&start=5&subtree=dv&type=dataset'
    assert_equal expected, @client.called_path
  end

  test 'unauthorized requests raise exception' do
    unauthorized_client = HttpClientMock.new(file_path: fixture_path('dataverse/collection_response/valid_response.json'), status_code: 401)
    service = Dataverse::CollectionService.new('https://example.com', http_client: unauthorized_client)
    assert_raises(Dataverse::CollectionService::UnauthorizedException) do
      service.find_collection_by_id('123')
    end
  end

  test 'get_my_collections parses response' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/my_dataverse_collections_response/valid_response.json'))
    service = Dataverse::CollectionService.new('https://example.com', http_client: client, api_key: 'KEY')
    res = service.get_my_collections
    assert_kind_of Dataverse::MyDataverseCollectionsResponse, res
  end

  test 'get_my_collections returns nil on 404' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/collection_response/valid_response.json'), status_code:404)
    service = Dataverse::CollectionService.new('https://example.com', http_client: client, api_key: 'KEY')
    assert_nil service.get_my_collections
  end

  test 'get_my_collections requires api key' do
    service = Dataverse::CollectionService.new('https://example.com', http_client: @client)
    assert_raises(Dataverse::CollectionService::ApiKeyRequiredException) do
      service.get_my_collections
    end
  end

  test 'search_collection_items returns nil on 404' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/search_response/valid_response.json'), status_code: 404)
    service = Dataverse::CollectionService.new('https://example.com', http_client: client)
    assert_nil service.search_collection_items('dv')
  end

  test 'search_collection_items raises on unauthorized' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/search_response/valid_response.json'), status_code: 401)
    service = Dataverse::CollectionService.new('https://example.com', http_client: client)
    assert_raises(Dataverse::CollectionService::UnauthorizedException) do
      service.search_collection_items('dv')
    end
  end
end
