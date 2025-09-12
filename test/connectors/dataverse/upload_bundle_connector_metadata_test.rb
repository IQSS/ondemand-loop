require 'test_helper'

class Dataverse::UploadBundleConnectorMetadataTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_title: 'My Collection',
      dataset_title: nil,
      collection_id: 'COL1',
      dataset_id: nil,
      auth_key: 'KEY'
    }
    @meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
  end

  test 'api_key detected' do
    assert @meta.api_key?
  end

  test 'to_h converts keys to strings' do
    assert_equal 'My Collection', @meta.to_h['collection_title']
  end

  test 'selection helpers' do
    assert @meta.display_collection?
    @meta.dataset_id = nil
    assert @meta.select_dataset?
    @meta.dataset_id = 'DS'
    @meta.dataset_title = 'T'
    assert @meta.display_dataset?
    refute @meta.api_key_required?
  end

  test 'api_key falls back to repo auth key when bundle lacks key' do
    @bundle.metadata.delete(:auth_key)
    repo = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'REPOKEY'))
    ::Configuration.repo_db.stubs(:get).with('https://demo.dataverse.org').returns(repo)
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    assert meta.api_key?
    assert_equal 'REPOKEY', meta.api_key.value
    assert meta.api_key.server?
  end

  test 'api_key required when no key provided' do
    @bundle.metadata.delete(:auth_key)
    repo = OpenStruct.new(metadata: OpenStruct.new(auth_key: nil))
    ::Configuration.repo_db.stubs(:get).with('https://demo.dataverse.org').returns(repo)
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.api_key?
    assert meta.api_key_required?
  end

  test 'method_missing returns nil for undefined methods' do
    result = @meta.undefined_method
    assert_nil result
  end

  test 'method_missing returns nil for undefined methods with arguments' do
    result = @meta.undefined_method('arg1', 'arg2')
    assert_nil result
  end

  test 'repo_name returns dataverse_url' do
    expected_url = 'https://demo.dataverse.org'
    assert_equal expected_url, @meta.repo_name
  end

  test 'configured? returns true when all required fields are present' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_title: 'My Collection',
      dataset_title: 'My Dataset',
      collection_id: 'COL1',
      dataset_id: 'DS1',
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    assert meta.configured?
  end

  test 'configured? returns false when api_key is missing' do
    @bundle.metadata.delete(:auth_key)
    ::Configuration.repo_db.stubs(:get).returns(nil)
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.configured?
  end

  test 'configured? returns false when dataset_id is missing' do
    @bundle.metadata[:dataset_id] = nil
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.configured?
  end

  test 'configured? returns false when dataset_title is missing' do
    @bundle.metadata[:dataset_title] = nil
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.configured?
  end

  test 'configured? returns false when collection_id is missing' do
    @bundle.metadata[:collection_id] = nil
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.configured?
  end

  test 'external_url returns dataset URL for draft version' do
    @bundle.metadata[:dataset_id] = 'DS123'
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    meta.stubs(:dataset_url).with(version: 'draft').returns('https://demo.dataverse.org/dataset.xhtml?persistentId=DS123&version=DRAFT')
    
    expected_url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=DS123&version=DRAFT'
    assert_equal expected_url, meta.external_url
  end

  test 'fetch_draft? returns true when api_key present, dataset_id present, and dataset_title nil' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      dataset_id: 'DS123',
      dataset_title: nil,
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    assert meta.fetch_draft?
  end

  test 'fetch_draft? returns false when api_key is missing' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      dataset_id: 'DS123',
      dataset_title: nil
    }
    ::Configuration.repo_db.stubs(:get).returns(nil)
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.fetch_draft?
  end

  test 'fetch_draft? returns false when dataset_id is missing' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      dataset_id: nil,
      dataset_title: nil,
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.fetch_draft?
  end

  test 'fetch_draft? returns false when dataset_title is present' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      dataset_id: 'DS123',
      dataset_title: 'My Dataset',
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.fetch_draft?
  end

  test 'select_collection? returns true when api_key present, collection_id nil, and dataset_id nil' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_id: nil,
      dataset_id: nil,
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    assert meta.select_collection?
  end

  test 'select_collection? returns false when api_key is missing' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_id: nil,
      dataset_id: nil
    }
    ::Configuration.repo_db.stubs(:get).returns(nil)
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.select_collection?
  end

  test 'select_collection? returns false when collection_id is present' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_id: 'COL123',
      dataset_id: nil,
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.select_collection?
  end

  test 'select_collection? returns false when dataset_id is present' do
    @bundle.metadata = {
      dataverse_url: 'https://demo.dataverse.org',
      collection_id: nil,
      dataset_id: 'DS123',
      auth_key: 'KEY'
    }
    meta = Dataverse::UploadBundleConnectorMetadata.new(@bundle)
    refute meta.select_collection?
  end
end
