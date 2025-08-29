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
end
