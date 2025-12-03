# frozen_string_literal: true

require 'test_helper'

class Dataverse::DataverseInstallationFileTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @fixture_path = Rails.root.join('..', 'e2e_tests', 'mock_repositories', 'dataverse', '__files', 'partial_installations_response.json').expand_path
  end

  teardown do
    travel_back
  end

  test 'installations loads active entries from file' do
    service = Dataverse::DataverseInstallationFile.new(path: @fixture_path, expires_in: 1.second)

    result = service.installations

    assert result.present?
    assert_equal '232FF393-29CB-4CB6-B2F8-344206F4EA15', result.first[:id]
    assert_equal 'Latin American Science Hub', result.first[:name]
  end

  test 'installations caches results until expiry' do
    payload_one = [
      { 'dvHubId' => 'dv-file', 'name' => 'File DV', 'hostname' => 'file.org', 'isActive' => true }
    ].to_json

    payload_two = [
      { 'dvHubId' => 'dv-file-2', 'name' => 'New File DV', 'hostname' => 'file2.org', 'isActive' => true }
    ].to_json

    File.expects(:read).with('/tmp/dv.json').twice.returns(payload_one).then.returns(payload_two)

    service = Dataverse::DataverseInstallationFile.new(path: '/tmp/dv.json', expires_in: 2.seconds)

    first = service.installations
    assert_equal 'dv-file', first.first[:id]

    second = service.installations
    assert_equal 'dv-file', second.first[:id], 'Expect cached data before expiry'

    travel 3.seconds

    third = service.installations
    assert_equal 'dv-file-2', third.first[:id], 'Expect refreshed data after cache expiry'
  end
end
