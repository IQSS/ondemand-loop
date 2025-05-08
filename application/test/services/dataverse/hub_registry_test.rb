# frozen_string_literal: true

require 'test_helper'

class Dataverse::HubRegistryTest < ActiveSupport::TestCase
  TEST_URL = 'https://my.hub.com/api/installation'

  setup do
    null_cache = ActiveSupport::Cache::NullStore.new
    @mock_client = mock('HttpClient')
    @target = Dataverse::HubRegistry.new(url: TEST_URL, http_client: @mock_client, cache: null_cache)
  end

  test 'installations fetches and parses installations successfully' do
    response_data = [
      { 'dvHubId' => 'dv1', 'name' => 'DV One', 'hostname' => 'dv1.org' },
      { 'dvHubId' => 'dv2', 'name' => 'DV Two', 'hostname' => 'dv2.org' }
    ]

    response = stub(success?: true, body: response_data.to_json)
    @mock_client.expects(:get).with(TEST_URL).returns(response)

    result = @target.installations

    assert_equal 2, result.size
    assert_equal 'dv1', result.first[:id]
    assert_equal 'DV Two', result.last[:name]
  end

  test 'installations returns empty array on unsuccessful response' do
    response = stub(success?: false, status: 500)
    @mock_client.expects(:get).with(TEST_URL).returns(response)

    result = @target.installations
    assert_equal [], result
  end

  test 'installations returns empty array when exception is raised' do
    @mock_client.expects(:get).with(TEST_URL).raises(StandardError, 'unexpected error')

    result = @target.installations
    assert_equal [], result
  end

  test 'installations uses cached result if available' do
    cached_data = [
      { id: 'dv-cached', name: 'Cached DV', hostname: 'cached.dv.org' }
    ]

    mock_cache = mock('HttpClient')
    mock_cache.expects(:fetch).with('dataverse_hub_installations', expires_in: 24.hours).returns(cached_data)
    @mock_client.expects(:get).never

    target = Dataverse::HubRegistry.new(url: TEST_URL, http_client: @mock_client, cache: mock_cache)
    result = target.installations

    assert_equal cached_data, result
  end
end
