require 'test_helper'

class Dataverse::Handlers::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::UploadBundleCreate.new
    RepoRegistry.repo_history.stubs(:add_repo)
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'create handles Dataverse url' do
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org')
    assert result.success?
    assert_equal 'dv.org', result.resource.name
  end

  test 'create handles collection url' do
    service = mock('service')
    collection = mock('collection')
    collection.stubs(:data).returns(OpenStruct.new({name: 'Collection Title', alias: 'collection_id', parents: []}))
    service.expects(:find_collection_by_id).with('collection_id').returns(collection)
    Dataverse::CollectionService.stubs(:new).returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/dataverse/collection_id')
    assert result.success?
    assert_equal 'Collection Title', result.resource.metadata[:collection_title]
  end

  test 'create handles dataset url' do
    service = mock('service')
    ds = mock('ds')
    ds.stubs(:data).returns(OpenStruct.new(parents: [{name: 'root'}, {name: 'col', identifier: 'c1'}]))
    ds.stubs(:metadata_field).with('title').returns('Dataset Title')
    ds.stubs(:version).returns('v1')
    service.expects(:find_dataset_version_by_persistent_id).with('DS1').returns(ds)
    Dataverse::DatasetService.stubs(:new).returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)
    result = @action.create(@project, object_url: 'http://dv.org/dataset.xhtml?persistentId=DS1')
    assert result.success?
    assert_equal 'Dataset Title', result.resource.metadata[:dataset_title]
  end

  test 'create handles dataset url with no parents' do
    dataset_service = mock('dataset_service')
    dataset = mock('dataset')
    dataset.stubs(:data).returns(OpenStruct.new(parents: []))
    dataset.stubs(:metadata_field).with('title').returns('Lonely Dataset')
    dataset.stubs(:version).returns('v1')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('DS_NO_PARENTS').returns(dataset)
    Dataverse::DatasetService.stubs(:new).returns(dataset_service)

    root_collection = mock('collection')
    root_collection.stubs(:data).returns(OpenStruct.new(name: 'Root Dataverse', alias: 'root'))
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: root_collection))

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle_no_parents')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'http://dv.org/dataset.xhtml?persistentId=DS_NO_PARENTS')

    assert result.success?
    assert_equal 'Lonely Dataset', result.resource.metadata[:dataset_title]
    assert_equal 'Root Dataverse', result.resource.metadata[:dataverse_title]
    assert_equal 'root', result.resource.metadata[:collection_id]
  end

  test 'create adds repo history' do
    Dataverse::CollectionService.stubs(:new).returns(stub(find_collection_by_id: OpenStruct.new(data: OpenStruct.new(name: 'root'))))
    UploadBundle.any_instance.stubs(:save)

    RepoRegistry.repo_history.expects(:add_repo).with('http://dv.org', ConnectorType::DATAVERSE, title: 'root', note: 'dataverse')

    @action.create(@project, object_url: 'http://dv.org')
  end
end
