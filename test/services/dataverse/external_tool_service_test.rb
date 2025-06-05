# frozen_string_literal: true

require 'test_helper'

class Dataverse::ExternalToolServiceTest < ActiveSupport::TestCase

  test 'process_callback should return Dataverse URL and the external tool API response' do
    http_client_mock = HttpClientMock.new(file_path: fixture_path('/dataverse/external_tool/valid_response.json'))
    target = Dataverse::ExternalToolService.new(http_client: http_client_mock)
    # Base64 encoding of:
    # http://dataverse.test.com:8080/external/tool?name=value
    callback = 'aHR0cDovL2RhdGF2ZXJzZS50ZXN0LmNvbTo4MDgwL2V4dGVybmFsL3Rvb2w/bmFtZT12YWx1ZQ=='
    result = target.process_callback(callback)

    assert_instance_of Dataverse::ExternalToolResponse, result[:response]
    assert_not_nil result[:response].status
    assert_not_nil result[:response].data

    assert_equal 'http', result[:dataverse_uri].scheme
    assert_equal 'dataverse.test.com', result[:dataverse_uri].host
    assert_equal '8080', result[:dataverse_uri].port.to_s
    assert http_client_mock.called?
  end
end

