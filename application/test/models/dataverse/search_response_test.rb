require "test_helper"

class Dataverse::SearchResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @response = Dataverse::SearchResponse.new(valid_json, 1, 10)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses search response" do
    assert_instance_of Dataverse::SearchResponse, @response
    assert_equal "OK", @response.status
    assert_instance_of Dataverse::SearchResponse::Data, @response.data
  end

  test "valid json parses response data" do
    data = @response.data
    assert_equal 1, data.page
    assert_equal 10, data.per_page
    assert_equal "*", data.q
    assert_equal 195882, data.total_count
    assert_equal 10, data.start
    assert_equal 20, data.count_in_response
  end

  test "empty json does not throw exception" do
    @invalid_response = Dataverse::SearchResponse.new(empty_json)
    assert_instance_of Dataverse::SearchResponse, @invalid_response
  end

  test "empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::SearchResponse.new(empty_string) }
  end

end
