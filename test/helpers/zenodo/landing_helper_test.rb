require 'test_helper'

class Zenodo::LandingHelperTest < ActionView::TestCase
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

  test 'zenodo_landing_url uses default URL components' do
    ::Configuration.stubs(:zenodo_default_url).returns('https://zenodo.org')
    result = zenodo_landing_url
    
    assert_equal '/explore/zenodo/zenodo.org/landing/:root', result
  end

  test 'zenodo_landing_url handles custom scheme and port' do
    # Test with a custom URL that has different scheme and port
    ::Configuration.stubs(:zenodo_default_url).returns('http://localhost:3000')
    # Clear the memoized default_url to pick up the new configuration
    Zenodo::ZenodoUrl.instance_variable_set(:@default_url, nil)
    
    expects(:explore_path).with(
      connector_type: 'zenodo',
      server_domain: 'localhost',
      server_scheme: 'http',
      server_port: 3000,
      object_type: 'landing',
      object_id: ':root'
    ).returns('/custom/landing')
    
    result = zenodo_landing_url
    assert_equal '/custom/landing', result
  ensure
    # Clean up: reset the memoized value to avoid affecting other tests
    Zenodo::ZenodoUrl.instance_variable_set(:@default_url, nil)
  end
end
