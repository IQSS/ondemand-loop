# frozen_string_literal: true
require 'test_helper'

class DataverseLandingPageHelperTest < ActionView::TestCase
  include Dataverse::LandingPageHelper

  test 'prev and next links rendered when page available' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_dataverse_landing_path).returns('/prev')
    html = link_to_landing_prev_page(page, {})
    assert_includes html, '/prev'

    stubs(:view_dataverse_landing_path).returns('/next')
    html = link_to_landing_next_page(page, {})
    assert_includes html, '/next'
  end

  test 'prev link nil on first page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_landing_prev_page(page, {})
  end

  test 'next link nil on last page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_landing_next_page(page, {})
  end
end
