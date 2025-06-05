require "test_helper"

class Dataverse::ExternalToolResponseTest < ActiveSupport::TestCase
  def setup
    @json_input = '{
      "status": "OK",
      "data": {
        "queryParameters": {
          "datasetPid": "doi:10.5072/FK2/VNRAWR",
          "datasetId": 9
        },
        "signedUrls": [
          {
            "name": "getDatasetDetailsFromPid",
            "httpMethod": "GET",
            "signedUrl": "http://localhost:8080/api/datasets/:persistentId/?persistentId=doi:10.5072/FK2/VNRAWR&until=2025-03-06T19:10:31.283&user=dataverseAdmin&method=GET&token=c8ce820387904516d574490f8a54aeed1e79a824187ffcaea88e18c20152402432a6d9d773fe45c3512ec7b24181cee12b9f3756f52bf4cda017aa44d080b4b1",
            "timeOut": 270
          },
          {
            "name": "getDatasetDetails",
            "httpMethod": "GET",
            "signedUrl": "http://localhost:8080/api/datasets/9?until=2025-03-06T19:10:31.284&user=dataverseAdmin&method=GET&token=1a69ebc5748242f2fc34c6ee22c7ba97e5d4c92317c0b72d337cf759d4fd69812510115ab0d86a21470a9b202e5054793ad6e0673c0fcd58e39fa890fcbcaeb7",
            "timeOut": 270
          }
        ]
      }
    }'

    @external_tool_response = Dataverse::ExternalToolResponse.new(@json_input)
  end

  test 'parses the status correctly' do
    assert_equal 'OK', @external_tool_response.status
  end

  test 'parses query parameters correctly' do
    query_params = @external_tool_response.data.query_parameters
    assert_equal 'doi:10.5072/FK2/VNRAWR', query_params.dataset_pid
    assert_equal 9, query_params.dataset_id
  end

  test 'parses signed URLs correctly' do
    signed_urls = @external_tool_response.data.signed_urls
    assert_equal 2, signed_urls.length

    first_url = signed_urls.first
    assert_equal 'getDatasetDetailsFromPid', first_url.name
    assert_equal 'GET', first_url.http_method
    assert_equal 270, first_url.time_out
    assert_includes first_url.signed_url, 'http://localhost:8080/api/datasets/:persistentId/'

    last_url = signed_urls.last
    assert_equal 'getDatasetDetails', last_url.name
    assert_equal 'GET', last_url.http_method
    assert_equal 270, last_url.time_out
    assert_includes last_url.signed_url, 'http://localhost:8080/api/datasets/9'
  end
end
