# frozen_string_literal: true
require "test_helper"

class Dataverse::ConnectorMetadataTest < ActiveSupport::TestCase

  test "should create read/write methods for any hash field names" do
    metadata = {
      id: '12345',
      status: 'RUNNING',
      location: '/some/location',
      test: 'anything value',
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_equal '12345', target.id
    assert_equal 'RUNNING', target.status
    assert_equal '/some/location', target.location
    assert_equal 'anything value', target.test

    target.id = 'updated'
    target.status = 'updated'
    target.location = 'updated'
    target.test = 'updated'

    assert_equal 'updated', target.id = 'updated'
    assert_equal 'updated', target.status
    assert_equal 'updated', target.location
    assert_equal 'updated', target.test
  end

  test "should not throw error when calling invalid methods" do
    metadata = {
      id: '12345'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_equal '12345', target.id
    assert_nil target.other
    assert_nil target.missing
    assert_nil target.name
  end

  test "to_h should hash with string keys" do
    metadata = {
      id: '12345',
      status: 'RUNNING',
    }
    file = DownloadFile.new
    file.metadata = metadata

    result = Dataverse::DownloadConnectorMetadata.new(file).to_h
    assert_equal({'id' => '12345', 'status' => 'RUNNING'}, result)
  end

  test 'repo_name from parents' do
    file = DownloadFile.new
    file.metadata = { parents: [{name: 'Root'}] }
    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_equal 'Root', target.repo_name

    file = DownloadFile.new
    file.metadata = { }
    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_equal 'N/A', target.repo_name
  end

  test 'files_url return nil when no dataset_id' do
    metadata = {
      dataverse_url: 'http://demo.dv:8080',
      dataset_id: nil,
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_nil target.files_url
  end

  test 'files_url overrides' do
    metadata = {
      dataverse_url: 'http://demo.dv:8080',
      dataset_id: 'doi:1',
      version: '2.0'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_includes target.files_url, 'server_scheme=http'
    assert_includes target.files_url, 'server_port=8080'
    assert_includes target.files_url, 'version=2.0'
  end
end
