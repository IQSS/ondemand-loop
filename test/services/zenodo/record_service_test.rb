require 'test_helper'

class Zenodo::RecordServiceTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    @base = 'https://zenodo.org'
  end

  test 'find_record returns parsed record' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'))
    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: client)
    record = service.find_record('11')
    assert_kind_of Zenodo::RecordResponse, record
    assert_equal '11', record.id
    assert_equal '/api/records/11', client.called_path
  end

  test 'find_record returns nil when not found' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'), status_code: 404)
    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: client)
    assert_nil service.find_record('99')
  end

  test 'get_or_create_deposition returns existing draft deposition' do
    headers = { 'Content-Type' => 'application/json', Zenodo::ApiService::AUTH_HEADER => 'Bearer KEY' }

    record_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/record_response.json')))
    list_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/depositions_draft_list.json')))
    dep_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/deposition_response.json')))

    http = mock('http')
    http.expects(:get).with('/api/records/11', headers: headers).returns(record_resp)
    http.expects(:get).with('/api/deposit/depositions?q=conceptrecid%3A10', headers: headers).returns(list_resp)
    http.expects(:get).with('/api/deposit/depositions/5', headers: headers).returns(dep_resp)

    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: http)
    dep = service.get_or_create_deposition('11', api_key: 'KEY', concept_id: nil)
    assert_instance_of Zenodo::DepositionResponse, dep
  end

  test 'get_or_create_deposition creates new draft when none exists' do
    headers = { 'Content-Type' => 'application/json', Zenodo::ApiService::AUTH_HEADER => 'Bearer KEY' }

    record_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/record_response.json')))
    list_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/depositions_no_draft_list.json')))
    new_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/newversion_response.json')))
    dep_resp = Common::HttpClient::Response.new(HttpResponseMock.new(fixture_path('zenodo/deposition_response.json')))

    http = mock('http')
    http.expects(:get).with('/api/records/11', headers: headers).returns(record_resp)
    http.expects(:get).with('/api/deposit/depositions?q=conceptrecid%3A10', headers: headers).returns(list_resp)
    http.expects(:post).with('/api/deposit/depositions/11/actions/newversion', headers: headers).returns(new_resp)
    http.expects(:get).with('/api/deposit/depositions/9', headers: headers).returns(dep_resp)

    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: http)
    dep = service.get_or_create_deposition('11', api_key: 'KEY', concept_id: nil)
    assert_equal 'https://zenodo.org/api/files/123', dep.bucket_url
  end

  test 'get_or_create_deposition handles not found' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'), status_code: 404)
    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: client)
    assert_nil service.get_or_create_deposition('11', api_key: 'KEY', concept_id: nil)
  end

  test 'get_or_create_deposition raises unauthorized' do
    client = HttpClientMock.new(file_path: fixture_path('zenodo/record_response.json'), status_code: 401)
    service = Zenodo::RecordService.new(zenodo_url: @base, http_client: client)
    assert_raises(Zenodo::ApiService::UnauthorizedException) do
      service.get_or_create_deposition('11', api_key: 'KEY', concept_id: nil)
    end
  end
end
