require "test_helper"

class Dataverse::DataverseResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'dataverse_response', 'valid_response.json'))
    @response = Dataverse::DataverseResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses dataverse response" do
    assert_instance_of Dataverse::DataverseResponse, @response
    assert_equal "OK", @response.status
    assert_instance_of Dataverse::DataverseResponse::Data, @response.data
  end

  test "valid json parses dataverse response data" do
    data = @response.data
    assert_equal 1234, data.id
    assert_equal "Dataverse_Alias", data.alias
    assert_equal "Sample Dataverse", data.name
    assert_equal "Sample Dataverse description", data.description
  end

  test "dataverse response on empty json does not throw exception" do
    @invalid_response = Dataverse::DataverseResponse.new(empty_json)
    assert_instance_of Dataverse::DataverseResponse, @invalid_response
  end

  test "dataverse response with empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::DataverseResponse.new(empty_string) }
  end

end
