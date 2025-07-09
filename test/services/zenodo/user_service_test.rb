require 'test_helper'

class Zenodo::UserServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @base = 'https://zenodo.org'
  end

  test 'list_depositions returns array of depositions' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/depositions_list_response.json'))
    service = Zenodo::UserService.new(@base, http_client: http, api_key: 'KEY')
    result = service.list_depositions
    assert_equal 2, result.length
    assert_equal '/api/deposit/depositions?page=1&size=20', http.called_path
  end

  test 'list_depositions raises unauthorized' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/depositions_list_response.json'), status_code: 401)
    service = Zenodo::UserService.new(@base, http_client: http, api_key: 'KEY')
    assert_raises(Zenodo::ApiService::UnauthorizedException) do
      service.list_depositions
    end
  end

  test 'list_user_records builds query correctly' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/records_list_response.json'))
    service = Zenodo::UserService.new(@base, http_client: http, api_key: 'KEY')
    records = service.list_user_records(q: 'test query', page: 2, per_page: 10, all_versions: true)
    assert_equal 2, records.length
    assert_equal '/api/records?all_versions=true&page=2&q=test%20query&size=10', http.called_path
  end

  test 'get_user_profile returns profile info' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/user_profile_response.json'))
    service = Zenodo::UserService.new(@base, http_client: http, api_key: 'KEY')
    profile = service.get_user_profile
    assert_equal 'John Doe', profile[:fullname]
    assert_equal 'john@example.com', profile[:email]
  end

  test 'get_user_profile returns nil on not found' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/user_profile_response.json'), status_code: 404)
    service = Zenodo::UserService.new(@base, http_client: http, api_key: 'KEY')
    assert_nil service.get_user_profile
  end
end
