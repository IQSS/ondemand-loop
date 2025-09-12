require 'test_helper'

class Zenodo::DownloadConnectorMetadataTest < ActiveSupport::TestCase
  def setup
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: 1, zenodo_url: 'https://zenodo_server.com'}
    @meta = Zenodo::DownloadConnectorMetadata.new(file)
  end

  test 'repo_name is Zenodo' do
    assert_equal 'Zenodo', @meta.repo_name
  end

  test 'explore_url uses type and id' do
    assert_equal '/explore/zenodo/zenodo_server.com/records/1?active_project=123', @meta.explore_url
  end

  test 'to_h and missing methods' do
    assert_nil @meta.unknown
    assert_equal({'type'=>'records', 'type_id'=>1, "zenodo_url"=>"https://zenodo_server.com"}, @meta.to_h)
  end

  test 'external_url returns nil when no zenodo_url' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: 1, zenodo_url: nil}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    assert_nil meta.external_url
  end

  test 'external_url returns nil when no type_id' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: nil, zenodo_url: 'https://zenodo.org'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    assert_nil meta.external_url
  end

  test 'external_url builds correct deposition URL for depositions type' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'depositions', type_id: 54321, zenodo_url: 'https://zenodo.org'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    expected_url = 'https://zenodo.org/uploads/54321'
    assert_equal expected_url, meta.external_url
  end

  test 'external_url returns zenodo_url for unsupported types' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'files', type_id: 1, zenodo_url: 'https://zenodo.org'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    assert_equal 'https://zenodo.org', meta.external_url
  end

  test 'external_url builds correct record URL for records type' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: 12345, zenodo_url: 'https://zenodo.org'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    expected_url = 'https://zenodo.org/records/12345'
    assert_equal expected_url, meta.external_url
  end

  test 'external_url works with different zenodo instances' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: 67890, zenodo_url: 'https://sandbox.zenodo.org'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    expected_url = 'https://sandbox.zenodo.org/records/67890'
    assert_equal expected_url, meta.external_url
  end

  test 'external_url works with custom port zenodo instance' do
    file = DownloadFile.new
    file.project_id = '123'
    file.metadata = {type: 'records', type_id: 999, zenodo_url: 'http://localhost:5000'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    expected_url = 'http://localhost:5000/records/999'
    assert_equal expected_url, meta.external_url
  end

  test 'repo_summary returns nil when no external_url' do
    file = DownloadFile.new
    file.project_id = '123'
    file.type = ConnectorType::ZENODO
    file.creation_date = Date.current
    file.metadata = {type: 'records', type_id: nil, zenodo_url: 'https://zenodo.org', title: 'Test Record'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    assert_nil meta.repo_summary
  end

  test 'repo_summary returns OpenStruct with correct attributes for records' do
    file = DownloadFile.new
    file.project_id = '123'
    file.type = ConnectorType::ZENODO
    file.creation_date = Date.current
    file.metadata = {type: 'records', type_id: 12345, zenodo_url: 'https://zenodo.org', title: 'Test Record'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    result = meta.repo_summary
    
    assert_not_nil result
    assert_equal ConnectorType::ZENODO, result.type
    assert_equal Date.current, result.date
    assert_equal 'Test Record', result.title
    assert_equal 'https://zenodo.org/records/12345', result.url
    assert_equal 'records', result.note
  end

  test 'repo_summary returns OpenStruct with correct attributes for depositions' do
    file = DownloadFile.new
    file.project_id = '123'
    file.type = ConnectorType::ZENODO
    file.creation_date = Date.current
    file.metadata = {type: 'depositions', type_id: 54321, zenodo_url: 'https://zenodo.org', title: 'Test Deposition'}
    meta = Zenodo::DownloadConnectorMetadata.new(file)
    
    result = meta.repo_summary
    
    assert_not_nil result
    assert_equal ConnectorType::ZENODO, result.type
    assert_equal Date.current, result.date
    assert_equal 'Test Deposition', result.title
    assert_equal 'https://zenodo.org/uploads/54321', result.url
    assert_equal 'depositions', result.note
  end
end
