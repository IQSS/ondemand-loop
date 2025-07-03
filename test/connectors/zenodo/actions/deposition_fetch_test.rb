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
end
