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
end
