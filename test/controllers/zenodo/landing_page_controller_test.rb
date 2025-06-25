require 'test_helper'

class Zenodo::LandingPageControllerTest < ActionDispatch::IntegrationTest
  test 'search delegates to service' do
    Zenodo::SearchService.any_instance.stubs(:search).returns(OpenStruct.new(items: []))
    get view_zenodo_landing_path, params: {query: 'test'}
    assert_response :success
  end

  test 'search error redirects' do
    Zenodo::SearchService.any_instance.stubs(:search).raises('fail')
    get view_zenodo_landing_path, params: {query: 't'}
    assert_redirected_to root_path
  end
end
