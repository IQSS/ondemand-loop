require 'test_helper'
require_relative '../../helpers/zenodo_helper'

class Zenodo::RecordResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    json = load_zenodo_fixture('record_response.json')
    @resp = Zenodo::RecordResponse.new(json)
  end

  test 'parses files and title' do
    assert_equal '11', @resp.id
    assert_equal '10', @resp.concept_id
    assert_equal 'Record Title', @resp.title
    assert_equal 2, @resp.files.size
    first = @resp.files.first
    assert_equal '1', first.id
    assert_equal 'data/file1.txt', first.filename
  end
end
