require 'test_helper'

class Zenodo::Handlers::DatasetSelectTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(zenodo_url: 'http://zenodo.org', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Zenodo::Handlers::DatasetSelect.new
  end

  test 'params schema includes deposition_id' do
    assert_includes @action.params_schema, :deposition_id
  end

  test 'edit not implemented' do
    assert_raises(NotImplementedError) { @action.edit(@bundle, {}) }
  end

  test 'update stores deposition information for draft deposition' do
    deposition = OpenStruct.new(id: '10', title: 'Test', bucket_url: 'burl', draft?: true)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)
    result = @action.update(@bundle, { deposition_id: '10' })
    assert result.success?
    assert_equal '10', @bundle.metadata[:deposition_id]
    assert_nil @bundle.metadata[:record_id]
    assert_equal 'Test', @bundle.metadata[:title]
  end

  test 'update stores record information for published deposition' do
    deposition = OpenStruct.new(id: '10', record_id: '99', title: 'Pub', bucket_url: 'burl', draft?: false)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('http://zenodo.org', api_key: 'KEY').returns(service)
    result = @action.update(@bundle, { deposition_id: '10' })
    assert result.success?
    assert_equal '99', @bundle.metadata[:record_id]
    assert_nil @bundle.metadata[:deposition_id]
  end
end
