require 'test_helper'
require_relative '../../helpers/zenodo_helper'

class Zenodo::SearchResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  test 'parses items' do
    json = load_zenodo_fixture('search_response.json')
    resp = Zenodo::SearchResponse.new(json, 1, 2)
    assert_equal 2, resp.items.size
    assert_equal 'Record One', resp.items.first.title
    assert_equal '1', resp.items.first.id
  end
end
