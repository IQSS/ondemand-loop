require 'test_helper'

class Dataverse::Actions::DatasetSelectTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'), collection_id: 'COL1')
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Actions::DatasetSelect.new
  end

  test 'edit returns select form' do
    @action.stubs(:datasets).returns(OpenStruct.new(items: []))
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/dataset_select_form', result.partial
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
end
