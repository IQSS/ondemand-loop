require 'test_helper'

class Zenodo::Handlers::DepositionCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(zenodo_url: 'https://zenodo.org', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Zenodo::Handlers::DepositionCreate.new
  end

  test 'params schema includes expected keys' do
    [:title, :upload_type, :description, :creators].each do |key|
      assert_includes @action.params_schema, key
    end
  end

  test 'edit returns connector result' do
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/zenodo/deposition_create_form', result.template
    assert_equal @bundle, result.locals[:upload_bundle]
  end

  test 'update stores deposition metadata' do
    dep_service = mock('dep')
    resp_json = load_zenodo_fixture('create_deposition_response.json')
    resp = Zenodo::CreateDepositionResponse.new(resp_json)
    dep_service.stubs(:create_deposition).returns(resp)
    Zenodo::DepositionService.stubs(:new).returns(dep_service)

    result = @action.update(@bundle, {title: 'Title', upload_type: 'dataset', description: 'Desc', creators: 'Doe, John'})
    assert result.success?
    assert_equal resp.id.to_s, @bundle.metadata[:deposition_id]
    assert_equal 'Title', @bundle.metadata[:title]
  end
end
