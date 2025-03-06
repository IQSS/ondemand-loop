require 'rails_helper'

RSpec.describe ExternalToolResponse, type: :model do
  let(:json_input) do
    ' {
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
  end

  describe "good json input" do

    let(:external_tool_response) { ExternalToolResponse.new(json_input) }

    it 'parses the status correctly' do
      expect(external_tool_response.status).to eq('OK')
    end

    it 'parses query parameters correctly' do
      expect(external_tool_response.data.query_parameters.dataset_pid).to eq('doi:10.5072/FK2/VNRAWR')
      expect(external_tool_response.data.query_parameters.dataset_id).to eq(9)
    end

    it 'parses signed URLs correctly' do
      expect(external_tool_response.data.signed_urls.length).to eq(2)

      first_url = external_tool_response.data.signed_urls.first
      expect(first_url.name).to eq('getDatasetDetailsFromPid')
      expect(first_url.http_method).to eq('GET')
      expect(first_url.time_out).to eq(270)
      expect(first_url.signed_url).to include('http://localhost:8080/api/datasets/:persistentId/')

      last_url = external_tool_response.data.signed_urls.last
      expect(last_url.name).to eq('getDatasetDetails')
      expect(last_url.http_method).to eq('GET')
      expect(last_url.time_out).to eq(270)
      expect(last_url.signed_url).to include('http://localhost:8080/api/datasets/9')
    end
  end
end
