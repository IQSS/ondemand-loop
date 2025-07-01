# frozen_string_literal: true
require 'test_helper'

class DataverseLandingPageHelperTest < ActionView::TestCase
  include Dataverse::LandingPageHelper

  test 'prev and next links rendered when page available' do
    items = (1..30).to_a.map {|n| {id: n, name: "foobar#{n}"}}
    page = Page.new(items, 2, 10, query: 'foo', filter_by: :name)
    expects(:view_dataverse_landing_path).with({:page => page.prev_page, :query => 'foo'}).returns('/prev')
    html = link_to_landing_prev_page(page, {})
    assert_includes html, '/prev'

    expects(:view_dataverse_landing_path).with({:page => page.next_page, :query => 'foo'}).returns('/next')
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
