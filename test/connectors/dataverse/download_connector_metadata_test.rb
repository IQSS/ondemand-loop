# frozen_string_literal: true
require "test_helper"

class Dataverse::DownloadConnectorMetadataTest < ActiveSupport::TestCase

  test "should create read/write methods for any hash field names" do
    metadata = {
      id: '12345',
      status: 'RUNNING',
      location: '/some/location',
      test: 'anything value',
    }
    file = DownloadFile.new
    file.project_id = '123'
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
    file.project_id = '123'
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

  test 'explore_url return nil when no dataset_id' do
    metadata = {
      dataverse_url: 'http://demo.dv:8080',
      dataset_id: nil,
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_nil target.explore_url
  end

  test 'explore_url overrides' do
    metadata = {
      dataverse_url: 'http://demo.dv:8080',
      dataset_id: 'doi:1',
      version: '2.0'
    }
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_includes target.explore_url, 'server_scheme=http'
    assert_includes target.explore_url, 'server_port=8080'
    assert_includes target.explore_url, 'version=2.0'
    assert_includes target.explore_url, 'active_project=123'
  end

  test 'external_url returns nil when no dataverse_url' do
    metadata = {
      dataverse_url: nil,
      dataset_id: 'doi:10.7910/DVN/ABC123'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_nil target.external_url
  end

  test 'external_url returns nil when no dataset_id' do
    metadata = {
      dataverse_url: 'http://demo.dv:8080',
      dataset_id: nil
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_nil target.external_url
  end

  test 'external_url builds correct dataset URL' do
    metadata = {
      dataverse_url: 'https://dataverse.example.com',
      dataset_id: 'doi:10.7910/DVN/ABC123'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    expected_url = 'https://dataverse.example.com/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FABC123'
    assert_equal expected_url, target.external_url
  end

  test 'external_url includes version when provided' do
    metadata = {
      dataverse_url: 'https://dataverse.example.com',
      dataset_id: 'doi:10.7910/DVN/ABC123',
      version: '2.0'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    expected_url = 'https://dataverse.example.com/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FABC123&version=2.0'
    assert_equal expected_url, target.external_url
  end

  test 'external_url handles different URL schemes and ports' do
    metadata = {
      dataverse_url: 'http://localhost:8080',
      dataset_id: 'doi:10.7910/DVN/XYZ789',
      version: '1.5'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    expected_url = 'http://localhost:8080/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FXYZ789&version=1.5'
    assert_equal expected_url, target.external_url
  end

  test 'repo_summary returns nil when no external_url' do
    metadata = {
      dataverse_url: nil,
      dataset_id: 'doi:10.7910/DVN/ABC123',
      title: 'Test Dataset'
    }
    file = DownloadFile.new
    file.type = ConnectorType::DATAVERSE
    file.creation_date = Date.current
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    assert_nil target.repo_summary
  end

  test 'repo_summary returns OpenStruct with correct attributes' do
    metadata = {
      dataverse_url: 'https://dataverse.example.com',
      dataset_id: 'doi:10.7910/DVN/ABC123',
      title: 'Test Dataset',
      version: '2.0'
    }
    file = DownloadFile.new
    file.type = ConnectorType::DATAVERSE
    file.creation_date = Date.current
    file.metadata = metadata

    target = Dataverse::DownloadConnectorMetadata.new(file)
    result = target.repo_summary

    assert_not_nil result
    assert_equal ConnectorType::DATAVERSE, result.type
    assert_equal Date.current, result.date
    assert_equal 'Test Dataset', result.title
    assert_equal 'https://dataverse.example.com/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FABC123&version=2.0', result.url
    assert_equal '2.0', result.note
  end
end
