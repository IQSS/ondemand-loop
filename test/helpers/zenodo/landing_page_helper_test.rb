# frozen_string_literal: true
require 'test_helper'

class ZenodoLandingPageHelperTest < ActionView::TestCase
  include Zenodo::LandingPageHelper

  test 'prev and next links rendered when page available' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_zenodo_landing_path).returns('/prev')
    html = link_to_search_prev_page('q', page, {})
    assert_includes html, '/prev'
    assert_includes html, 'btn btn-sm btn-outline-dark'

    stubs(:view_zenodo_landing_path).returns('/next')
    html = link_to_search_next_page('q', page, {})
    assert_includes html, '/next'
    assert_includes html, 'btn btn-sm btn-outline-dark'
  end

  test 'prev link nil on first page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_search_prev_page('q', page, {})
  end

  test 'next link nil on last page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_search_next_page('q', page, {})
  end
end

