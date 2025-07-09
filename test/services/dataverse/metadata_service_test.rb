require 'test_helper'

class Dataverse::MetadataServiceTest < ActiveSupport::TestCase
  include DataverseHelper

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/citation_metadata_response/valid_response.json'))
    @service = Dataverse::MetadataService.new('https://example.com', http_client: @client)
  end

  test 'get_citation_metadata parses response' do
    metadata = @service.get_citation_metadata
    assert_kind_of Dataverse::CitationMetadataResponse, metadata
    assert_equal 'OK', metadata.status
    assert_includes metadata.subjects, 'Agricultural Sciences'
  end

  test 'returns nil when not found' do
    not_found_client = HttpClientMock.new(file_path: fixture_path('dataverse/citation_metadata_response/valid_response.json'), status_code: 404)
    service = Dataverse::MetadataService.new('https://example.com', http_client: not_found_client)
    assert_nil service.get_citation_metadata
  end
end
