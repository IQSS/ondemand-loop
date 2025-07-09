require 'test_helper'

class Zenodo::DepositionServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @base = 'https://zenodo.org'
  end

  test 'create_deposition returns response object' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/create_deposition_response.json'))
    service = Zenodo::DepositionService.new(@base, http_client: http, api_key: 'KEY')
    req = Zenodo::CreateDepositionRequest.new(title: 't', upload_type: 'software', description: 'd', creators: [{name: 'me'}])
    resp = service.create_deposition(req)
    assert_instance_of Zenodo::CreateDepositionResponse, resp
    assert_equal 1, resp.id
    assert_equal '/api/deposit/depositions', http.called_path
  end

  test 'create_deposition raises on unauthorized' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/create_deposition_response.json'), status_code: 401)
    service = Zenodo::DepositionService.new(@base, http_client: http, api_key: 'KEY')
    req = Zenodo::CreateDepositionRequest.new(title: 't', upload_type: 'software', description: 'd', creators: [])
    assert_raises(Zenodo::ApiService::UnauthorizedException) { service.create_deposition(req) }
  end

  test 'find_deposition returns deposition response' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/deposition_response.json'))
    service = Zenodo::DepositionService.new(@base, http_client: http, api_key: 'KEY')
    resp = service.find_deposition('1')
    assert_instance_of Zenodo::DepositionResponse, resp
    assert_equal 1, resp.id
    assert_equal '/api/deposit/depositions/1', http.called_path
  end

  test 'find_deposition returns nil when not found' do
    http = HttpClientMock.new(file_path: fixture_path('zenodo/deposition_response.json'), status_code: 404)
    service = Zenodo::DepositionService.new(@base, http_client: http, api_key: 'KEY')
    assert_nil service.find_deposition('1')
  end
end
