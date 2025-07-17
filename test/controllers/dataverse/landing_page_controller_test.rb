require 'test_helper'

class Dataverse::LandingPageControllerTest < ActionDispatch::IntegrationTest
  test 'index loads installations' do
    dvs = [{
      id: 'dv-test-01',
      name: 'DV Test 01',
      hostname: 'https://dv-01.org',
    },
     {
       id: 'dv-test-02',
       name: 'DV Test 02',
       hostname: 'https://dv-02.org',
     }]
    registry = mock('reg'); registry.stubs(:installations).returns(dvs)
    DataverseHubRegistry.stubs(:registry).returns(registry)
    get view_dataverse_landing_url
    assert_response :success
  end

  test 'index filters installations by name' do
    dvs = [
      { id: 'dv-test-01', name: 'DV Test 01', hostname: 'https://dv-01.org' },
      { id: 'dv-test-02', name: 'Another DV', hostname: 'https://dv-02.org' }
    ]
    registry = mock('reg'); registry.stubs(:installations).returns(dvs)
    DataverseHubRegistry.stubs(:registry).returns(registry)
    get view_dataverse_landing_url, params: { query: 'Test 01' }
    assert_response :success
    assert_includes @response.body, 'DV Test 01'
    assert_not_includes @response.body, 'Another DV'
  end

  test 'index redirects on service error' do
    DataverseHubRegistry.stubs(:registry).raises(StandardError.new('boom'))
    get view_dataverse_landing_url
    assert_redirected_to root_path
    assert_match 'Dataverse Installations service error', flash[:alert]
  end
end
