require 'test_helper'

class LandingExploreHelperTest < ActionView::TestCase
  include Zenodo::LandingHelper

  def setup
    @repo_url = OpenStruct.new(domain: 'zenodo.org', scheme_override: nil, port_override: nil)
  end

  test 'prev and next links rendered when pages available' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:explore_path).returns('/link')
    html = link_to_explore_prev_page('q', page, @repo_url, {})
    assert_includes html, '/link'
    html = link_to_explore_next_page('q', page, @repo_url, {})
    assert_includes html, '/link'
  end

  test 'prev returns nil on first page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_explore_prev_page('q', page, @repo_url, {})
  end

  test 'next returns nil on last page' do
    page = Page.new((1..10).to_a, 1, 10)
    assert_nil link_to_explore_next_page('q', page, @repo_url, {})
  end
end
