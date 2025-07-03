require 'test_helper'

class Dataverse::Actions::CollectionSelectTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Actions::CollectionSelect.new
  end

  test 'edit returns form' do
    @action.stubs(:collections).returns([])
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/collection_select_form', result.partial
  end

  test 'update stores collection data' do
    @action.stubs(:collections).returns(OpenStruct.new(items:[OpenStruct.new(identifier:'c1', name:'title')]))
    @bundle.stubs(:metadata).returns({})
    result = @action.update(@bundle, {collection_id: 'c1'})
    assert result.success?
    assert_equal 'c1', @bundle.metadata[:collection_id]
  end

  test 'collections helper uses service' do
    service = mock('service')
    service.expects(:get_my_collections).returns(OpenStruct.new(items: []))
    Dataverse::CollectionService.stubs(:new).returns(service)
    result = @action.send(:collections, @bundle)
    assert_equal 0, result.items.size
  end
end
