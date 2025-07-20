require 'test_helper'

class Zenodo::Actions::DepositionFetchTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(zenodo_url: 'http://zenodo.org', deposition_id: '10', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @bundle.stubs(:repo_url).returns('http://zenodo.org/deposit/10')
    @action = Zenodo::Actions::DepositionFetch.new
  end

  test 'update fetches deposition and stores data' do
    dep = OpenStruct.new(title: 't', bucket_url: 'b', draft?: false)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(dep)
    Zenodo::DepositionService.stubs(:new).returns(service)
    result = @action.update(@bundle, {})
    assert result.success?
    assert_equal 't', @bundle.metadata[:title]
  end

  test 'update handles missing deposition' do
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(nil)
    Zenodo::DepositionService.stubs(:new).returns(service)
    result = @action.update(@bundle, {})
    refute result.success?
  end

  test 'update creates deposition from record when needed' do
    meta = OpenStruct.new(zenodo_url: 'http://zenodo.org', record_id: '11', deposition_id: nil, api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @bundle.stubs(:repo_url).returns('http://zenodo.org/record/11')

    dep = OpenStruct.new(id: '99', title: 't', bucket_url: 'b', draft?: true)
    r_service = mock('record_service')
    r_service.expects(:get_or_create_deposition).with('11', api_key: 'KEY').returns(dep)
    Zenodo::RecordService.stubs(:new).returns(r_service)

    result = @action.update(@bundle, {})
    assert result.success?
    assert_equal '99', @bundle.metadata[:deposition_id]
  end
end
