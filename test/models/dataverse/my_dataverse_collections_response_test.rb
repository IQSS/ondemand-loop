require 'test_helper'

class Dataverse::MyDataverseCollectionsResponseTest < ActiveSupport::TestCase
  include FileFixtureHelper

  def setup
    json = load_file_fixture(File.join('dataverse','my_dataverse_collections_response','valid_response.json'))
    @resp = Dataverse::MyDataverseCollectionsResponse.new(json, page:1, per_page:1)
  end

  test 'parses items and pagination' do
    assert_equal 'OK', @resp.status
    assert_equal 2, @resp.total_count
    assert_equal 2, @resp.total_pages
    assert_equal 'DV1', @resp.items.first.name
  end
end
