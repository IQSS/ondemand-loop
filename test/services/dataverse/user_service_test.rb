require 'test_helper'

class Dataverse::UserServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @base = 'https://demo.dataverse.org'
  end

  test 'get_user_profile returns profile' do
    http = HttpClientMock.new(file_path: fixture_path('dataverse/user_profile_response/valid_response.json'))
    service = Dataverse::UserService.new(@base, http_client: http, api_key: 'KEY')
    profile = service.get_user_profile
    assert_instance_of Dataverse::UserProfileResponse, profile
    assert_equal 'Doe, John', profile.full_name
    assert_equal '/api/users/:me', http.called_path
  end

  test 'get_user_profile returns nil when not found' do
    http = HttpClientMock.new(file_path: fixture_path('dataverse/user_profile_response/valid_response.json'), status_code: 404)
    service = Dataverse::UserService.new(@base, http_client: http, api_key: 'KEY')
    assert_nil service.get_user_profile
  end

  test 'raises without api_key' do
    service = Dataverse::UserService.new(@base, http_client: HttpClientMock.new(file_path: fixture_path('dataverse/user_profile_response/valid_response.json')))
    assert_raises(Dataverse::ApiService::ApiKeyRequiredException) { service.get_user_profile }
  end
end
