require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::RecordResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    json = load_zenodo_fixture('record_response.json')
    @resp = Zenodo::RecordResponse.new(json)
  end

  test 'parses metadata and files' do
    assert_equal '11', @resp.id
    assert_equal '10', @resp.concept_id
    assert_equal 'Record Title', @resp.title
    assert_equal 'Record description', @resp.description
    assert_equal '2025-01-02', @resp.publication_date
    assert_equal 2, @resp.files.size
    first = @resp.files.first
    assert_equal '1', first.id
    assert_equal 'data/file1.txt', first.filename
    assert_equal 'md5:abc', first.checksum
    assert_not @resp.draft?
    assert_equal 'published', @resp.version
  end
end
