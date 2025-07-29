# frozen_string_literal: true

require 'test_helper'

class Dataverse::DataverseHubTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  TEST_URL = 'https://my.hub.com/api/installations'

  setup do
    @mock_client = mock('HttpClient')
    @expiry = 1.second
    @target = Dataverse::DataverseHub.new(
      url: TEST_URL,
      http_client: @mock_client,
      expires_in: @expiry
    )
  end

  teardown do
    travel_back
  end

  test 'installations fetches and stores non-empty results filtering inactive' do
    response_data = [
      { 'dvHubId' => 'dv1', 'name' => 'DV One', 'hostname' => 'dv1.org', 'isActive' => true },
      { 'dvHubId' => 'dv2', 'name' => 'DV Two', 'hostname' => 'dv2.org', 'isActive' => true  },
      { 'dvHubId' => 'dv3', 'name' => 'DV Two', 'hostname' => 'dv2.org', 'isActive' => false  }
    ]
    response = stub(success?: true, body: response_data.to_json)

    @mock_client.expects(:get).with(TEST_URL).returns(response)

    result = @target.installations

    assert_equal 2, result.size
    assert_equal 'dv1', result.first[:id]
    assert_equal 'dv2', result.last[:id]
  end

  test 'installations returns stored data without re-fetching if not expired' do
    response_data = [
      { 'dvHubId' => 'dv-stored', 'name' => 'Stored DV', 'hostname' => 'stored.org' }
    ]
    response = stub(success?: true, body: response_data.to_json)

    @mock_client.expects(:get).with(TEST_URL).once.returns(response)

    result1 = @target.installations
    result2 = @target.installations

    assert_equal result1, result2
    assert_equal 'dv-stored', result2.first[:id]
  end

  test 'installations re-fetches after expiry and updates cache with new value' do
    first_response = stub(success?: true, body: [
      { 'dvHubId' => 'dv1', 'name' => 'Old DV', 'hostname' => 'old.org' }
    ].to_json)

    second_response = stub(success?: true, body: [
      { 'dvHubId' => 'dv2', 'name' => 'New DV', 'hostname' => 'new.org' }
    ].to_json)

    @mock_client.expects(:get).with(TEST_URL).twice.returns(first_response).then.returns(second_response)

    result1 = @target.installations
    assert_equal 'dv1', result1.first[:id]

    travel @expiry + 1.second

    result2 = @target.installations
    assert_equal 'dv2', result2.first[:id]
  end

  test 'installations does not update stored data when fetch result is empty' do
    valid_response = stub(success?: true, body: [
      { 'dvHubId' => 'dv-initial', 'name' => 'Initial DV', 'hostname' => 'initial.org' }
    ].to_json)

    empty_response = stub(success?: true, body: [].to_json)

    @mock_client.expects(:get).with(TEST_URL).twice.returns(valid_response).then.returns(empty_response)

    result1 = @target.installations
    assert_equal 'dv-initial', result1.first[:id]

    travel @expiry + 1.second

    result2 = @target.installations
    assert_equal 'dv-initial', result2.first[:id], 'Should not be overwritten with empty data'
  end

  test 'installations returns existing data if fetch raises error' do
    good_response = stub(success?: true, body: [
      { 'dvHubId' => 'dv-good', 'name' => 'Good DV', 'hostname' => 'good.org' }
    ].to_json)

    @mock_client.expects(:get).with(TEST_URL).twice.returns(good_response).then.raises(StandardError, 'boom')

    result1 = @target.installations
    assert_equal 'dv-good', result1.first[:id]

    travel @expiry + 1.second

    result2 = @target.installations
    assert_equal 'dv-good', result2.first[:id], 'Should return cached data after fetch error'
  end
end
