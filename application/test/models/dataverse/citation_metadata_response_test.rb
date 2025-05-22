require "test_helper"

class Dataverse::CitationMetadataResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'citation_metadata_response', 'valid_response.json'))
    @response = Dataverse::CitationMetadataResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses CitationMetadata response" do
    assert_instance_of Dataverse::CitationMetadataResponse, @response
    assert_equal "OK", @response.status
  end

  test "valid json parses valid subjects" do
    assert_equal 15, @response.subjects.count
    assert_equal "Agricultural Sciences", @response.subjects.first
    assert_equal "Demo Only", @response.subjects.last
  end

  test "citation metadata response on empty json does not throw exception" do
    @invalid_response = Dataverse::CitationMetadataResponse.new(empty_json)
    assert_instance_of Dataverse::CitationMetadataResponse, @invalid_response
    assert_empty @invalid_response.subjects
  end

  test "citation metadata response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::CitationMetadataResponse.new(empty_string) }
  end

end
