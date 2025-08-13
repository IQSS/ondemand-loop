require 'test_helper'

class Dataverse::Handlers::LandingTest < ActiveSupport::TestCase
  def setup
    @action = Dataverse::Handlers::Landing.new
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :page
    assert_includes @action.params_schema, :query
  end

  test 'show loads installations' do
    dvs = [
      { id: 'dv-test-01', name: 'DV Test 01', hostname: 'https://dv-01.org' },
      { id: 'dv-test-02', name: 'DV Test 02', hostname: 'https://dv-02.org' }
    ]
    registry = mock('reg'); registry.stubs(:installations).returns(dvs)
    DataverseHubRegistry.stubs(:registry).returns(registry)
    res = @action.show({})
    assert res.success?
    assert_equal 2, res.locals[:installations_page].page_items.size
  end

  test 'show filters installations by name' do
    dvs = [
      { id: 'dv-test-01', name: 'DV Test 01', hostname: 'https://dv-01.org' },
      { id: 'dv-test-02', name: 'Another DV', hostname: 'https://dv-02.org' }
    ]
    registry = mock('reg'); registry.stubs(:installations).returns(dvs)
    DataverseHubRegistry.stubs(:registry).returns(registry)
    res = @action.show(query: 'Test 01')
    assert res.success?
    items = res.locals[:installations_page].page_items
    assert_equal 1, items.size
    assert_equal 'DV Test 01', items.first[:name]
  end

  test 'show returns error on service failure' do
    DataverseHubRegistry.stubs(:registry).raises(StandardError.new('boom'))
    res = @action.show({})
    assert_not res.success?
    assert_equal I18n.t('dataverse.landing.index.dataverse_installations_service_error'), res.message[:alert]
  end
end
