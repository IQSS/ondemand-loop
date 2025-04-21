require "test_helper"

class Dataverse::SearchResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @response = Dataverse::SearchResponse.new(valid_json, 1, 20)
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

  test "valid json parses search response data" do
    data = @response.data
    assert_equal 1, data.page
    assert_equal 20, data.per_page
    assert_equal "*", data.q
    assert_equal 195882, data.total_count
    assert_equal 10, data.start
    assert_equal 20, data.count_in_response
    assert_equal 20, data.items.count
  end

  test "valid dataset item in search response" do
    dataset = @response.data.items.first
    assert_instance_of Dataverse::SearchResponse::Data::DatasetItem, dataset
    assert_match /Traditional martial arts, subak, folk dance/, dataset.name
    assert_equal "doi:10.7910/DVN/VIQT9F", dataset.global_id
    assert_equal "junho", dataset.identifier_of_dataverse
    assert_equal "junho song Dataverse", dataset.name_of_dataverse
    assert_equal 1, dataset.file_count
  end

  test "valid dataverse item in search response" do
    dataverse = @response.data.items[1]
    assert_instance_of Dataverse::SearchResponse::Data::DataverseItem, dataverse
    assert_equal "junho song Dataverse", dataverse.name
    assert_equal "junho", dataverse.identifier
  end

  test "search response on empty json does not throw exception" do
    @invalid_response = Dataverse::SearchResponse.new(empty_json)
    assert_instance_of Dataverse::SearchResponse, @invalid_response
  end

  test "search response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::SearchResponse.new(empty_string) }
  end

end
