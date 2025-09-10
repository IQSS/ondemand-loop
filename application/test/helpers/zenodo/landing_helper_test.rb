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

  test 'zenodo_landing_url uses default URL components' do
    default_zenodo = mock('zenodo_url')
    default_zenodo.stubs(:domain).returns('zenodo.org')
    default_zenodo.stubs(:scheme_override).returns(nil)
    default_zenodo.stubs(:port_override).returns(nil)
    Zenodo::ZenodoUrl.stubs(:default_url).returns(default_zenodo)
    stubs(:explore_path).returns('/zenodo/landing')
    
    result = zenodo_landing_url
    
    assert_equal '/zenodo/landing', result
  end

  test 'zenodo_landing_url handles custom scheme and port' do
    default_zenodo = mock('zenodo_url')
    default_zenodo.stubs(:domain).returns('localhost')
    default_zenodo.stubs(:scheme_override).returns('http')
    default_zenodo.stubs(:port_override).returns(3000)
    Zenodo::ZenodoUrl.stubs(:default_url).returns(default_zenodo)
    
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
  end

  test 'zenodo_landing_url fallback when default_url is nil' do
    Zenodo::ZenodoUrl.stubs(:default_url).returns(nil)
    
    expects(:explore_path).with(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'landing',
      object_id: ':root'
    ).returns('/fallback/landing')
    
    result = zenodo_landing_url
    assert_equal '/fallback/landing', result
  end
end
