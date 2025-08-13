require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::DepositionsResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  test 'parses depositions' do
    json = load_zenodo_fixture('depositions_list_response.json')
    resp = Zenodo::DepositionsResponse.new(json, page: 1, per_page: 20, total_count: 2)
    assert_equal 2, resp.items.size
    assert_equal '1', resp.items.first.id
  end
end
