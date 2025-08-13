require 'test_helper'

class Dataverse::Handlers::DatasetSelectTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'), collection_id: 'COL1')
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Handlers::DatasetSelect.new
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :dataset_id
  end

  test 'edit not implemented' do
    assert_raises(NotImplementedError) { @action.edit(@bundle, {}) }
  end

  test 'update stores dataset id and title' do
    @action.stubs(:datasets).returns(OpenStruct.new(items: [OpenStruct.new(global_id: 'id', name: 'title')]))
    @bundle.stubs(:metadata).returns({})
    result = @action.update(@bundle, {dataset_id: 'id'})
    assert result.success?
    assert_equal 'id', @bundle.metadata[:dataset_id]
  end

  test 'dataset_title helper finds name' do
    datasets = OpenStruct.new(items: [OpenStruct.new(global_id: 'g', name: 'Title')])
    @action.stubs(:datasets).returns(datasets)
    assert_equal 'Title', @action.send(:dataset_title, @bundle, 'g')
  end

  test 'dataset_title returns nil when not found' do
    datasets = OpenStruct.new(items: [OpenStruct.new(global_id: 'g', name: 'Title')])
    @action.stubs(:datasets).returns(datasets)
    assert_nil @action.send(:dataset_title, @bundle, 'missing')
  end

  test 'datasets fetches via collection service' do
    service = mock('collections')
    service.expects(:search_collection_items)
           .with('COL1', page: 1, per_page: 100, include_collections: false, include_drafts: true)
           .returns(OpenStruct.new(data: :results))
    Dataverse::CollectionService.expects(:new).with('http://dv.org', api_key: 'KEY').returns(service)
    assert_equal :results, @action.send(:datasets, @bundle)
  end
end
