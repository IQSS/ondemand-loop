require 'test_helper'

class Zenodo::DisplayRepoControllerResolverTest < ActionDispatch::IntegrationTest
  def setup
    @resolver = Zenodo::DisplayRepoControllerResolver.new
    @resolver.define_singleton_method(:view_zenodo_landing_path) { '/view/zenodo' }
  end

  test 'record url returns record path' do
    url = 'https://zenodo.org/records/12'
    result = @resolver.get_controller_url(url)
    assert_equal '/view/zenodo/records/12', result.redirect_url
    assert result.success?
  end

  test 'zenodo root url returns landing path' do
    url = 'https://zenodo.org'
    result = @resolver.get_controller_url(url)
    assert_equal '/view/zenodo', result.redirect_url
  end
end
