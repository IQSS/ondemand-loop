require 'test_helper'

class Dataverse::Handlers::CollectionSelectTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Handlers::CollectionSelect.new
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :collection_id
  end

  test 'edit returns form' do
    json = { success: true, data: { items: [], total_count: 0 } }.to_json
    response = Dataverse::MyDataverseCollectionsResponse.new(json)
    @action.stubs(:collections).returns(response)
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/collection_select_form', result.template
  end

  test 'update stores collection data' do
    json = { success: true, data: { items: [{ identifier: 'c1', name: 'title' }], total_count: 1 } }.to_json
    response = Dataverse::MyDataverseCollectionsResponse.new(json)
    @action.stubs(:collections).returns(response)
    @bundle.stubs(:metadata).returns({})
    result = @action.update(@bundle, { collection_id: 'c1' })
    assert result.success?
    assert_equal 'c1', @bundle.metadata[:collection_id]
  end

  test 'collections helper uses service' do
    json = { success: true, data: { items: [], total_count: 0 } }.to_json
    response = Dataverse::MyDataverseCollectionsResponse.new(json)
    service = mock('service')
    service.expects(:get_my_collections).returns(response)
    Dataverse::CollectionService.stubs(:new).returns(service)
    result = @action.send(:collections, @bundle)
    assert_equal 0, result.items.size
  end

  test 'collection_title finds name and returns nil when missing' do
    json = { success: true, data: { items: [{ identifier: 'c1', name: 'Title1' }], total_count: 1 } }.to_json
    response = Dataverse::MyDataverseCollectionsResponse.new(json)
    @action.stubs(:collections).returns(response)
    assert_equal 'Title1', @action.send(:collection_title, @bundle, 'c1')
    assert_nil @action.send(:collection_title, @bundle, 'c2')
  end
end
