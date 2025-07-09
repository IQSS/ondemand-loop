require 'test_helper'

class Zenodo::SearchServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('zenodo/search_response.json'))
    @service = Zenodo::SearchService.new('https://zenodo.org', http_client: @client)
  end

  test 'search builds URL and parses response' do
    response = @service.search('query', page: 2, per_page: 5)
    assert_kind_of Zenodo::SearchResponse, response
    assert_equal 2, response.page
    assert_equal '/api/records?page=2&q=query&size=5', @client.called_path
  end

  test 'search returns nil when request fails' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/search_response.json'), status_code: 404)
    service = Zenodo::SearchService.new('https://zenodo.org', http_client: client)
    assert_nil service.search('missing')
  end
end
