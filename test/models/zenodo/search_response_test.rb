require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::SearchResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  test 'parses items' do
    json = load_zenodo_fixture('search_response.json')
    resp = Zenodo::SearchResponse.new(json, 1, 2)
    assert_equal 2, resp.items.size
    assert_equal 'Record One', resp.items.first.title
    first = resp.items.first
    assert_equal '1', first.id
    assert_equal 'Desc one', first.description
    assert_equal '2024-01-01', first.publication_date
    assert_equal 1, first.files.size
    assert_equal 'md5:111', first.files.first.checksum
    assert_equal 1, resp.page
    assert_equal 2, resp.per_page
    assert_equal 2, resp.total_count
    assert_equal 1, resp.total_pages
    assert resp.first_page?
    assert resp.last_page?
  end
end
