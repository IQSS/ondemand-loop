require 'test_helper'

class Zenodo::Handlers::DatasetFormTabsTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Zenodo::Handlers::DatasetFormTabs.new
  end

  test 'params schema is empty' do
    assert_empty @action.params_schema
  end

  test 'edit returns tabs form partial' do
    empty_resp = Zenodo::DepositionsResponse.new('[]', page: 1, per_page: 20, total_count: 0)
    @action.stubs(:depositions).returns(empty_resp)
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/zenodo/dataset_form_tabs', result.template
  end

  test 'update not implemented' do
    assert_raises(NotImplementedError) { @action.update(@bundle, {}) }
  end

  test 'depositions fetched via user service' do
    meta = OpenStruct.new(zenodo_url: 'http://zen', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    service = mock('service')
    resp = Zenodo::DepositionsResponse.new('[{"id":1},{"id":2}]', page: 1, per_page: 20, total_count: 2)
    service.expects(:list_depositions).returns(resp)
    Zenodo::UserService.expects(:new).with('http://zen', api_key: 'KEY').returns(service)
    assert_equal resp, @action.send(:depositions, @bundle)
  end
end
