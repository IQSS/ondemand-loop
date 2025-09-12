require 'test_helper'

class Dataverse::Handlers::UploadBundleCreateFromDatasetTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::UploadBundleCreateFromDataset.new
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

  test 'create handles published dataset with parent hierarchy' do
    @metadata.stubs(:auth_key).returns('dataset-api-key')
    
    # Mock dataset with parent hierarchy
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [
      {name: 'Harvard Dataverse', identifier: 'harvard'}, # root
      {name: 'Social Sciences', identifier: 'socialsciences'} # parent collection
    ])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('COVID-19 Survey Data')

    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.7910/DVN/DATASET1', version: '1.0').returns(dataset)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'dataset-api-key').returns(dataset_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('harvard_dataset_bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DATASET1&version=1.0')
    
    assert result.success?
    assert_equal 'dataverse.harvard.edu', result.resource.name
    assert_equal 'Harvard Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'Social Sciences', result.resource.metadata[:collection_title]
    assert_equal 'COVID-19 Survey Data', result.resource.metadata[:dataset_title]
    assert_equal 'socialsciences', result.resource.metadata[:collection_id]
    assert_equal 'doi:10.7910/DVN/DATASET1', result.resource.metadata[:dataset_id]
  end

  test 'create handles dataset with no parents (root collection)' do
    @metadata.stubs(:auth_key).returns('root-api-key')
    
    # Mock dataset with empty parents
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('Root Dataset')

    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.5072/FK2/ROOTDS', version: nil).returns(dataset)
    Dataverse::DatasetService.expects(:new).with('https://demo.dataverse.org', api_key: 'root-api-key').returns(dataset_service)
    
    # Mock root collection fetch
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Demo Dataverse', alias: 'root'))
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with(':root').returns(root_collection)
    Dataverse::CollectionService.expects(:new).with('https://demo.dataverse.org', api_key: 'root-api-key').returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('demo_root_dataset')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/ROOTDS')
    
    assert result.success?
    assert_equal 'Demo Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'root', result.resource.metadata[:collection_title]
    assert_equal 'Root Dataset', result.resource.metadata[:dataset_title]
    assert_equal 'root', result.resource.metadata[:collection_id]
  end

  test 'create handles draft dataset without API key' do
    @metadata.stubs(:auth_key).returns(nil)
    
    # Mock root collection service (no dataset service call for draft without API key)
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Test University Dataverse', alias: 'testuniversity'))
    collection_service = mock('collection_service')
    collection_service.expects(:find_collection_by_id).with(':root').returns(root_collection)
    Dataverse::CollectionService.expects(:new).with('https://dataverse.test.edu').returns(collection_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('test_draft_bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://dataverse.test.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/DRAFT123&version=DRAFT')
    
    assert result.success?
    assert_equal 'Test University Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'testuniversity', result.resource.metadata[:collection_title]
    assert_nil result.resource.metadata[:dataset_title]
    assert_equal 'testuniversity', result.resource.metadata[:collection_id]
    assert_equal 'doi:10.5072/FK2/DRAFT123', result.resource.metadata[:dataset_id]
  end

  test 'create handles draft dataset with API key' do
    @metadata.stubs(:auth_key).returns('draft-api-key')
    
    # Mock dataset with parents (should call dataset service since API key exists)
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [
      {name: 'Private Dataverse', identifier: 'private'},
      {name: 'Research Collection', identifier: 'research'}
    ])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('Draft Research Data')

    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.5072/FK2/PRIVATEDS', version: ':draft').returns(dataset)
    Dataverse::DatasetService.expects(:new).with('https://private.dataverse.edu', api_key: 'draft-api-key').returns(dataset_service)
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('private_draft_bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://private.dataverse.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/PRIVATEDS&version=DRAFT')
    
    assert result.success?
    assert_match /Dataset upload bundle created/, result.message[:notice]
    assert_equal 'Private Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'Research Collection', result.resource.metadata[:collection_title]
    assert_equal 'Draft Research Data', result.resource.metadata[:dataset_title]
    assert_equal 'research', result.resource.metadata[:collection_id]
  end

  test 'create handles dataset not found error' do
    @metadata.stubs(:auth_key).returns('valid-key')
    
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.5072/FK2/MISSING', version: '1.0').returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://notfound.dataverse.org', api_key: 'valid-key').returns(dataset_service)
    
    result = @action.create(@project, object_url: 'https://notfound.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/MISSING&version=1.0')
    
    assert_not result.success?
    assert_match(/not found/, result.message[:alert])
    assert_match(/https:\/\/notfound\.dataverse\.org/, result.message[:alert])
  end

  test 'create handles authentication error' do
    @metadata.stubs(:auth_key).returns('invalid-key')
    
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Unauthorized'))
    Dataverse::DatasetService.expects(:new).with('https://secure.dataverse.edu', api_key: 'invalid-key').returns(dataset_service)
    
    result = @action.create(@project, object_url: 'https://secure.dataverse.edu/dataset.xhtml?persistentId=doi:10.5072/FK2/SECURE&version=2.0')
    
    assert_not result.success?
    assert_match(/authorization/, result.message[:alert])
    assert_match(/https:\/\/secure\.dataverse\.edu/, result.message[:alert])
  end

  test 'create adds repo history with dataset title' do
    @metadata.stubs(:auth_key).returns('history-key')
    
    dataset = mock('dataset')
    dataset.stubs(:data).returns(OpenStruct.new(parents: [{name: 'Root'}, {name: 'Parent', identifier: 'parent'}]))
    dataset.stubs(:metadata_field).with('title').returns('History Dataset')

    Dataverse::DatasetService.stubs(:new).returns(stub(find_dataset_version_by_persistent_id: dataset))
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('history_bundle')
    UploadBundle.any_instance.stubs(:save)

    ::Configuration.repo_history.expects(:add_repo).with(
      'https://history.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/HISTORY&version=1.5',
      ConnectorType::DATAVERSE,
      title: 'History Dataset',
      note: '1.5'
    )
    
    result = @action.create(@project, object_url: 'https://history.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/HISTORY&version=1.5')
    assert result.success?
  end

  test 'create adds repo history with draft version note for draft without API key' do
    @metadata.stubs(:auth_key).returns(nil)

    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Draft Root', alias: 'draftroot'))
    Dataverse::CollectionService.expects(:new).with('https://version.dataverse.org').returns(stub(find_collection_by_id: root_collection))
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('draft_history_bundle')
    UploadBundle.any_instance.stubs(:save)

    ::Configuration.repo_history.expects(:add_repo).with(
      'https://version.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/HISTORY&version=DRAFT',
      ConnectorType::DATAVERSE,
      title: 'doi:10.5072/FK2/HISTORY', # no dataset title available without API key => defaults to dataset_id
      note: ':draft'
    )
    
    @action.create(@project, object_url: 'https://version.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/HISTORY&version=DRAFT')
  end

  test 'create when repo info not found in database' do
    ::Configuration.repo_db.stubs(:get).returns(nil)
    
    root_collection = mock('root_collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Unknown Dataverse', alias: 'unknown'))
    Dataverse::CollectionService.expects(:new).with('https://unknown.dataverse.org').returns(stub(find_collection_by_id: root_collection))
    
    Common::FileUtils.any_instance.stubs(:normalize_name).returns('unknown_bundle')
    UploadBundle.any_instance.stubs(:save)

    result  = @action.create(@project, object_url: 'https://unknown.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/HISTORY&version=DRAFT')
    assert result.success?
    assert_equal 'unknown.dataverse.org', result.resource.name
  end

  test 'error helper returns proper ConnectorResult' do
    result = @action.send(:error, 'Test dataset error message')
    
    assert_not result.success?
    assert_equal 'Test dataset error message', result.message[:alert]
    assert_instance_of ConnectorResult, result
  end
end