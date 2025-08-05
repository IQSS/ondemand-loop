require 'test_helper'

class Zenodo::DisplayRepoControllerResolverTest < ActionDispatch::IntegrationTest
  def setup
    @resolver = Zenodo::DisplayRepoControllerResolver.new
  end

  test 'record url returns record path' do
    url = 'https://zenodo.org/records/12'
    result = @resolver.get_controller_url(url)
    assert_equal '/explore/zenodo/zenodo.org/records/12', result.redirect_url
    assert result.success?
  end

  test 'deposition url returns deposition path' do
    url = 'https://zenodo.org/deposit/34'
    result = @resolver.get_controller_url(url)
    assert_equal '/explore/zenodo/zenodo.org/depositions/34', result.redirect_url
    assert result.success?
  end

  test 'zenodo root url returns landing path' do
    url = 'https://zenodo.org'
    result = @resolver.get_controller_url(url)
    assert_equal '/explore/zenodo/zenodo.org/actions/landing', result.redirect_url
  end
end
