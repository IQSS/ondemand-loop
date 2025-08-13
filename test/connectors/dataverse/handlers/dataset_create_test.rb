require 'test_helper'

class Dataverse::Handlers::DatasetCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'), collection_id: 'COL1')
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Handlers::DatasetCreate.new
  end

  test 'params schema includes expected keys' do
    [:title, :author, :description, :contact_email, :subject].each do |key|
      assert_includes @action.params_schema, key
    end
  end

  test 'edit not implemented' do
    assert_raises(NotImplementedError) { @action.edit(@bundle, {}) }
  end

  test 'update stores dataset metadata' do
    ds_service = mock('ds'); ds_service.stubs(:create_dataset).returns(OpenStruct.new(persistent_id: 'pid', id: 1))
    Dataverse::DatasetService.stubs(:new).returns(ds_service)
    result = @action.update(@bundle, {title: 'Title', author: 'A', description: '', contact_email: '', subject: 's'})
    assert result.success?
    assert_equal 'pid', @bundle.metadata[:dataset_id]
  end
end
