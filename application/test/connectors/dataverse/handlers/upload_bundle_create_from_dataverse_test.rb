require 'test_helper'

class Dataverse::Handlers::UploadBundleCreateFromDataverseTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::UploadBundleCreateFromDataverse.new
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

  test 'create handles Dataverse root url without API key' do
    @metadata.stubs(:auth_key).returns(nil)
    
    # Mock collection service and root collection
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Harvard Dataverse'))
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with(':root').returns(root_collection)
    Dataverse::CollectionService.expects(:new).with('https://dataverse.harvard.edu', api_key: nil).returns(collection_service)
    
    # Mock file utils and upload bundle
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('harvard_dataverse_bundle123')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://dataverse.harvard.edu/')
    
    assert result.success?
    assert_equal 'dataverse.harvard.edu', result.resource.name
    assert_equal 'Harvard Dataverse', result.resource.metadata[:dataverse_title]
    assert_nil result.resource.metadata[:collection_title]
    assert_nil result.resource.metadata[:dataset_title]
    assert_nil result.resource.metadata[:collection_id]
    assert_nil result.resource.metadata[:dataset_id]
  end

  test 'create handles Dataverse root url with API key' do
    @metadata.stubs(:auth_key).returns('test-api-key')
    
    # Mock collection service with API key
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Demo Dataverse'))
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with(':root').returns(root_collection)
    Dataverse::CollectionService.expects(:new).with('https://demo.dataverse.org', api_key: 'test-api-key').returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('demo_dataverse_bundle456')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://demo.dataverse.org')
    
    assert result.success?
    assert_equal 'demo.dataverse.org', result.resource.name
    assert_equal 'Demo Dataverse', result.resource.metadata[:dataverse_title]
  end

  test 'create adds repo history with correct parameters' do
    @metadata.stubs(:auth_key).returns(nil)
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Test Dataverse'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('test_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    ::Configuration.repo_history.expects(:add_repo).with(
      'https://test.dataverse.org',
      ConnectorType::DATAVERSE,
      title: 'Test Dataverse',
      note: 'dataverse'
    )
    
    @action.create(@project, object_url: 'https://test.dataverse.org')
  end

  test 'create sets correct upload bundle metadata' do
    @metadata.stubs(:auth_key).returns('api-key-123')
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'My Dataverse'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('my_dataverse_xyz')
    
    # Capture the upload bundle being created
    upload_bundle = nil
    UploadBundle.any_instance.stubs(:save) do |bundle|
      upload_bundle = bundle
    end
    
    result = @action.create(@project, object_url: 'https://my.dataverse.edu/')
    
    # Verify bundle properties
    assert_equal @project.id, result.resource.project_id
    assert_equal 'https://my.dataverse.edu/', result.resource.remote_repo_url
    assert_equal ConnectorType::DATAVERSE, result.resource.type
    assert_equal 'my.dataverse.edu', result.resource.name
    
    # Verify metadata structure
    metadata = result.resource.metadata
    assert_equal 'https://my.dataverse.edu', metadata[:dataverse_url]
    assert_equal 'My Dataverse', metadata[:dataverse_title]
    assert_nil metadata[:collection_title]
    assert_nil metadata[:dataset_title]
    assert_nil metadata[:collection_id]
    assert_nil metadata[:dataset_id]
  end

  test 'create handles authentication error' do
    @metadata.stubs(:auth_key).returns('invalid-key')
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Unauthorized'))
    Dataverse::CollectionService.expects(:new).with('https://secure.dataverse.org', api_key: 'invalid-key').returns(collection_service)
    
    result = @action.create(@project, object_url: 'https://secure.dataverse.org')
    
    assert_not result.success?
    assert_match(/authorization/, result.message[:alert])
    assert_match(/https:\/\/secure\.dataverse\.org/, result.message[:alert])
  end

  test 'create when repo info not found in database' do
    ::Configuration.repo_db.stubs(:get).returns(nil)
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Unknown Dataverse'))
    Dataverse::CollectionService.expects(:new).with('https://unknown.dataverse.com', api_key: nil).returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('unknown_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'https://unknown.dataverse.com')
    
    assert result.success?
    assert_equal 'unknown.dataverse.com', result.resource.name
  end

  test 'create logs info messages correctly' do
    @metadata.stubs(:auth_key).returns(nil)
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Log Test Dataverse'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('log_test_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    # Expect info logging calls
    @action.expects(:log_info).with('Creating upload bundle from dataverse', { 
      project_id: @project.id, 
      remote_repo_url: 'https://log.dataverse.test' 
    })
    @action.expects(:log_info).with('Upload bundle created from dataverse', { 
      bundle_id: kind_of(String)
    })
    
    @action.create(@project, object_url: 'https://log.dataverse.test')
  end

  test 'create logs error for authentication exception' do
    @metadata.stubs(:auth_key).returns('bad-key')
    
    collection_service = mock('collection_service')
    exception = Dataverse::DatasetService::UnauthorizedException.new('Access denied')
    collection_service.expects(:find_collection_by_id).raises(exception)
    Dataverse::CollectionService.expects(:new).returns(collection_service)
    
    @action.expects(:log_error).with('Repo URL requires authentication', { 
      dataverse: 'https://auth.dataverse.test' 
    }, exception)
    
    result = @action.create(@project, object_url: 'https://auth.dataverse.test')
    
    assert_not result.success?
  end

  test 'create uses correct translation keys for success message' do
    @metadata.stubs(:auth_key).returns(nil)
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Translation Test'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('translation_bundle')
    UploadBundle.any_instance.stubs(:save)
    
    I18n.expects(:t).with('connectors.dataverse.handlers.upload_bundle_create_from_dataverse.message_success', name: 'translation.dataverse.test').returns('Success message')
    
    result = @action.create(@project, object_url: 'https://translation.dataverse.test')
    
    assert result.success?
    assert_equal 'Success message', result.message[:notice]
  end

  test 'create uses correct translation keys for authentication error' do
    @metadata.stubs(:auth_key).returns('invalid')
    
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Auth failed'))
    Dataverse::CollectionService.expects(:new).returns(collection_service)
    
    I18n.expects(:t).with('connectors.dataverse.handlers.upload_bundle_create_from_dataverse.message_authentication_error', url: 'https://auth-error.dataverse.test').returns('Auth error message')
    
    result = @action.create(@project, object_url: 'https://auth-error.dataverse.test')
    
    assert_not result.success?
    assert_equal 'Auth error message', result.message[:alert]
  end

  test 'error helper returns proper ConnectorResult' do
    result = @action.send(:error, 'Test error message')
    
    assert_not result.success?
    assert_equal 'Test error message', result.message[:alert]
    assert_instance_of ConnectorResult, result
  end
end