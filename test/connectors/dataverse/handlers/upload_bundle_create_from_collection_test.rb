require 'test_helper'

class Dataverse::Handlers::UploadBundleCreateFromCollectionTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::UploadBundleCreateFromCollection.new
    ::Configuration.repo_history.stubs(:add_repo)
    
    # Mock repo database
    @repo_info = mock('repo_info')
    @metadata = mock('metadata')
    @repo_info.stubs(:metadata).returns(@metadata)
    ::Configuration.repo_db.stubs(:get).returns(@repo_info)
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'create handles collection with parent dataverse' do
    @metadata.stubs(:auth_key).returns('collection-api-key')
    
    # Mock collection with parent hierarchy
    collection = mock('collection')
    collection_data = OpenStruct.new(
      name: 'Social Sciences Collection',
      alias: 'socialsciences',
      parents: [{ name: 'Harvard Dataverse', identifier: 'harvard' }]
    )
    collection.stubs(:data).returns(collection_data)
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with('socialsciences').returns(collection)
    Dataverse::CollectionService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'collection-api-key').returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('harvard_collection_bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://dataverse.harvard.edu/dataverse/socialsciences')
    
    assert result.success?
    assert_equal 'dataverse.harvard.edu', result.resource.name
    assert_equal 'Harvard Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'Social Sciences Collection', result.resource.metadata[:collection_title]
    assert_nil result.resource.metadata[:dataset_title]
    assert_equal 'socialsciences', result.resource.metadata[:collection_id]
    assert_nil result.resource.metadata[:dataset_id]
  end

  test 'create handles collection without parent dataverse' do
    @metadata.stubs(:auth_key).returns('root-collection-key')
    
    # Mock collection with no parents
    collection = mock('collection')
    collection_data = OpenStruct.new(
      name: 'Orphan Collection',
      alias: 'orphan',
      parents: []
    )
    collection.stubs(:data).returns(collection_data)
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with('orphan').returns(collection)
    Dataverse::CollectionService.expects(:new).with('https://demo.dataverse.org', api_key: 'root-collection-key').returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('demo_orphan_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://demo.dataverse.org/dataverse/orphan')
    
    assert result.success?
    assert_equal 'demo.dataverse.org', result.resource.name
    assert_nil result.resource.metadata[:dataverse_title] # no parent, so nil
    assert_equal 'Orphan Collection', result.resource.metadata[:collection_title]
    assert_equal 'orphan', result.resource.metadata[:collection_id]
  end

  test 'create handles collection without API key' do
    @metadata.stubs(:auth_key).returns(nil)
    
    collection = mock('collection')
    collection_data = OpenStruct.new(
      name: 'Public Collection',
      alias: 'public',
      parents: [{ name: 'Open Dataverse', identifier: 'open' }]
    )
    collection.stubs(:data).returns(collection_data)
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with('public').returns(collection)
    Dataverse::CollectionService.expects(:new).with('https://open.dataverse.edu', api_key: nil).returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('open_public_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://open.dataverse.edu/dataverse/public')
    
    assert result.success?
    assert_equal 'open.dataverse.edu', result.resource.name
    assert_equal 'Open Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'Public Collection', result.resource.metadata[:collection_title]
  end

  test 'create handles collection not found error' do
    @metadata.stubs(:auth_key).returns('valid-key')
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with('missing').returns(nil)
    Dataverse::CollectionService.expects(:new).with('https://notfound.dataverse.org', api_key: 'valid-key').returns(collection_service)
    
    result = @action.create(@project, object_url: 'https://notfound.dataverse.org/dataverse/missing')
    
    assert_not result.success?
    assert_match(/not found/, result.message[:alert])
    assert_match(/https:\/\/notfound\.dataverse\.org/, result.message[:alert])
  end

  test 'create handles authentication error' do
    @metadata.stubs(:auth_key).returns('invalid-key')
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with('private').raises(Dataverse::DatasetService::UnauthorizedException.new('Unauthorized'))
    Dataverse::CollectionService.expects(:new).with('https://secure.dataverse.edu', api_key: 'invalid-key').returns(collection_service)
    
    result = @action.create(@project, object_url: 'https://secure.dataverse.edu/dataverse/private')
    
    assert_not result.success?
    assert_match(/authorization/, result.message[:alert])
    assert_match(/https:\/\/secure\.dataverse\.edu/, result.message[:alert])
  end

  test 'create adds repo history with collection title priority' do
    @metadata.stubs(:auth_key).returns('history-key')
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(
      name: 'Test Collection',
      alias: 'testcol',
      parents: [{ name: 'History Dataverse', identifier: 'history' }]
    ))
    
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: collection))
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('history_collection_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    ::Configuration.repo_history.expects(:add_repo).with(
      'https://history.dataverse.org/dataverse/testcol',
      ConnectorType::DATAVERSE,
      title: 'Test Collection', # collection title has priority over root title
      note: 'collection'
    )
    
    @action.create(@project, object_url: 'https://history.dataverse.org/dataverse/testcol')
  end

  test 'create adds repo history with root title fallback when collection title is nil' do
    @metadata.stubs(:auth_key).returns('fallback-key')
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(
      name: nil, # collection title is nil
      alias: 'unnamed',
      parents: [{ name: 'Fallback Dataverse', identifier: 'fallback' }]
    ))
    
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: collection))
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('fallback_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    ::Configuration.repo_history.expects(:add_repo).with(
      'https://fallback.dataverse.org/dataverse/unnamed',
      ConnectorType::DATAVERSE,
      title: 'Fallback Dataverse', # falls back to root title when collection title is nil
      note: 'collection'
    )
    
    @action.create(@project, object_url: 'https://fallback.dataverse.org/dataverse/unnamed')
  end

  test 'create sets correct upload bundle metadata structure' do
    @metadata.stubs(:auth_key).returns('metadata-key')
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(
      name: 'Metadata Test Collection',
      alias: 'metadata_collection',
      parents: [{ name: 'Test Root Dataverse', identifier: 'testroot' }]
    ))
    
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: collection))
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('metadata_test_bundle')
    
    # Capture the upload bundle being created
    upload_bundle = nil
    UploadBundle.any_instance.stubs(:save) do |bundle|
      upload_bundle = bundle
    end
    
    result = @action.create(@project, object_url: 'https://metadata.dataverse.test/dataverse/metadata_collection')
    
    # Verify bundle properties
    assert_equal @project.id, result.resource.project_id
    assert_equal 'https://metadata.dataverse.test/dataverse/metadata_collection', result.resource.remote_repo_url
    assert_equal ConnectorType::DATAVERSE, result.resource.type
    assert_equal 'metadata.dataverse.test', result.resource.name
    
    # Verify metadata structure (collection-specific)
    metadata = result.resource.metadata
    assert_equal 'https://metadata.dataverse.test', metadata[:dataverse_url]
    assert_equal 'Test Root Dataverse', metadata[:dataverse_title]
    assert_equal 'Metadata Test Collection', metadata[:collection_title]
    assert_nil metadata[:dataset_title] # always nil for collections
    assert_equal 'metadata_collection', metadata[:collection_id]
    assert_nil metadata[:dataset_id] # always nil for collections
  end

  test 'create when repo info not found in database' do
    ::Configuration.repo_db.stubs(:get).returns(nil)
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(
      name: 'Unknown Collection',
      alias: 'unknown_collection',
      parents: []
    ))
    
    Dataverse::CollectionService.expects(:new).with('https://unknown.dataverse.com', api_key: nil).returns(stub(find_collection_by_id: collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('unknown_collection_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://unknown.dataverse.com/dataverse/unknown_collection')
    
    assert result.success?
    assert_equal 'unknown.dataverse.com', result.resource.name
  end

  test 'create logs info messages correctly' do
    @metadata.stubs(:auth_key).returns('log-key')
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(name: 'Log Collection', alias: 'log_collection', parents: []))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('log_collection_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    # Expect info logging calls
    @action.expects(:log_info).with('Creating upload bundle from collection', { 
      project_id: @project.id, 
      remote_repo_url: 'https://log.dataverse.test/dataverse/log_collection' 
    })
    @action.expects(:log_info).with('Upload bundle created from collection', { 
      bundle_id: kind_of(String)
    })
    
    @action.create(@project, object_url: 'https://log.dataverse.test/dataverse/log_collection')
  end

  test 'create logs error for authentication exception' do
    @metadata.stubs(:auth_key).returns('bad-key')
    
    exception = Dataverse::DatasetService::UnauthorizedException.new('Access denied')
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).raises(exception)
    Dataverse::CollectionService.expects(:new).returns(collection_service)
    
    @action.expects(:log_error).with('Repo URL requires authentication', { 
      dataverse: 'https://auth-error.dataverse.test/dataverse/auth_collection' 
    }, exception)
    
    result = @action.create(@project, object_url: 'https://auth-error.dataverse.test/dataverse/auth_collection')
    
    assert_not result.success?
  end

  test 'create uses correct translation keys for success message' do
    @metadata.stubs(:auth_key).returns(nil)
    
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new(name: 'Translation Collection', alias: 'trans_collection', parents: []))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('translation_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    I18n.expects(:t).with('connectors.dataverse.handlers.upload_bundle_create_from_collection.message_success', name: 'translation.test').returns('Collection success message')
    
    result = @action.create(@project, object_url: 'https://translation.test/dataverse/trans_collection')
    
    assert result.success?
    assert_equal 'Collection success message', result.message[:notice]
  end

  test 'create uses correct translation keys for collection not found error' do
    @metadata.stubs(:auth_key).returns('test-key')
    
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: nil))
    
    I18n.expects(:t).with('connectors.dataverse.handlers.upload_bundle_create_from_collection.message_collection_not_found', url: 'https://not-found-test.dataverse.org/dataverse/missing').returns('Collection not found message')
    
    result = @action.create(@project, object_url: 'https://not-found-test.dataverse.org/dataverse/missing')
    
    assert_not result.success?
    assert_equal 'Collection not found message', result.message[:alert]
  end

  test 'create uses correct translation keys for authentication error' do
    @metadata.stubs(:auth_key).returns('invalid')
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Auth failed'))
    Dataverse::CollectionService.expects(:new).returns(collection_service)
    
    I18n.expects(:t).with('connectors.dataverse.handlers.upload_bundle_create_from_collection.message_authentication_error', url: 'https://auth-test.dataverse.org/dataverse/private').returns('Collection auth error message')
    
    result = @action.create(@project, object_url: 'https://auth-test.dataverse.org/dataverse/private')
    
    assert_not result.success?
    assert_equal 'Collection auth error message', result.message[:alert]
  end

  test 'error helper returns proper ConnectorResult' do
    result = @action.send(:error, 'Test collection error message')
    
    assert_not result.success?
    assert_equal 'Test collection error message', result.message[:alert]
    assert_instance_of ConnectorResult, result
  end
end