require 'test_helper'

class Dataverse::Handlers::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::UploadBundleCreate.new
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

  test 'create handles Dataverse url without API key' do
    @metadata.stubs(:auth_key).returns(nil)
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: nil).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/')
    assert result.success?
    assert_equal 'dv.org', result.resource.name
  end

  test 'create handles Dataverse url with API key' do
    @metadata.stubs(:auth_key).returns('test-api-key')
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: 'test-api-key').returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/')
    assert result.success?
    assert_equal 'dv.org', result.resource.name
  end

  test 'create handles collection url' do
    @metadata.stubs(:auth_key).returns('collection-api-key')
    service = mock('service')
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new({name: 'Collection Title', alias: 'collection_id', parents: []}))
    service.expects(:find_collection_by_id).with('collection_id').returns(collection)
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: 'collection-api-key').returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/dataverse/collection_id')
    assert result.success?
    assert_equal 'Collection Title', result.resource.metadata[:collection_title]
  end

  test 'create handles dataset url' do
    @metadata.stubs(:auth_key).returns('dataset-api-key')
    service = mock('service')
    ds = mock('ds')
    ds.stubs(:data).returns(OpenStruct.new(parents: [{name: 'root'}, {name: 'col', identifier: 'c1'}]))
    ds.stubs(:metadata_field).with('title').returns('Dataset Title')
    ds.stubs(:version).returns('v1')
    service.expects(:find_dataset_version_by_persistent_id).with('DS1', version: nil).returns(ds)
    Dataverse::DatasetService.expects(:new).with('http://dv.org', api_key: 'dataset-api-key').returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/dataset.xhtml?persistentId=DS1')
    assert result.success?
    assert_equal 'Dataset Title', result.resource.metadata[:dataset_title]
  end

  test 'create handles dataset url with no parents' do
    @metadata.stubs(:auth_key).returns('no-parents-api-key')
    dataset_service = mock('dataset_service')
    dataset = mock('dataset')
    dataset.stubs(:data).returns(OpenStruct.new(parents: []))
    dataset.stubs(:metadata_field).with('title').returns('Lonely Dataset')
    dataset.stubs(:version).returns('v1')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('DS_NO_PARENTS', version: nil).returns(dataset)
    Dataverse::DatasetService.expects(:new).with('http://dv.org', api_key: 'no-parents-api-key').returns(dataset_service)

    root_collection = mock('collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Root Dataverse', alias: 'root'))
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: 'no-parents-api-key').returns(stub(find_collection_by_id: root_collection))

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle_no_parents')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'http://dv.org/dataset.xhtml?persistentId=DS_NO_PARENTS')

    assert result.success?
    assert_equal 'Lonely Dataset', result.resource.metadata[:dataset_title]
    assert_equal 'Root Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'root', result.resource.metadata[:collection_id]
  end

  test 'create adds repo history' do
    @metadata.stubs(:auth_key).returns(nil)
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)

    ::Configuration.repo_history.expects(:add_repo).with('http://dv.org', ConnectorType::DATAVERSE, title: 'root', note: 'dataverse')

    @action.create(@project, object_url: 'http://dv.org')
  end

  test 'create handles authentication error' do
    @metadata.stubs(:auth_key).returns('invalid-key')
    service = mock('service')
    service.expects(:find_collection_by_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Unauthorized'))
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: 'invalid-key').returns(service)

    result = @action.create(@project, object_url: 'http://dv.org')
    
    assert_not result.success?
    assert_match(/authorization/, result.message[:alert])
  end

  test 'create handles collection not found error' do
    @metadata.stubs(:auth_key).returns(nil)
    service = mock('service')
    service.expects(:find_collection_by_id).with('missing_collection').returns(nil)
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: nil).returns(service)

    result = @action.create(@project, object_url: 'http://dv.org/dataverse/missing_collection')
    
    assert_not result.success?
    assert_match(/not found/, result.message[:alert])
  end

  test 'create handles dataset not found error' do
    @metadata.stubs(:auth_key).returns(nil)
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('MISSING_DATASET', version: nil).returns(nil)
    Dataverse::DatasetService.expects(:new).with('http://dv.org', api_key: nil).returns(service)

    result = @action.create(@project, object_url: 'http://dv.org/dataset.xhtml?persistentId=MISSING_DATASET')
    
    assert_not result.success?
    assert_match(/not found/, result.message[:alert])
  end

  test 'create handles general error' do
    @metadata.stubs(:auth_key).returns(nil)
    Dataverse::CollectionService.expects(:new).raises(StandardError.new('Network error'))

    result = @action.create(@project, object_url: 'http://dv.org')
    
    assert_not result.success?
    assert_match(/Error/, result.message[:alert])
    assert_match(/Upload Bundle/, result.message[:alert])
  end

  test 'create when repo info not found in database' do
    ::Configuration.repo_db.stubs(:get).returns(nil)
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: nil).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)
    
    result = @action.create(@project, object_url: 'http://dv.org')
    assert result.success?
  end
end
