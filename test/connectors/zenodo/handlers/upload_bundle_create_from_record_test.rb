require 'test_helper'

class Zenodo::Handlers::UploadBundleCreateFromRecordTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Handlers::UploadBundleCreateFromRecord.new
    ::Configuration.repo_history.stubs(:add_repo)
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'record not found returns error' do
    url_data = OpenStruct.new(deposition?: false, record?: true, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: '99', deposition_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    records_service = mock('records')
    records_service.expects(:find_record).with('99').returns(nil)
    Zenodo::RecordService.stubs(:new).returns(records_service)

    result = @action.create(@project, object_url: 'https://zenodo.org/record/99')
    refute result.success?
  end

  test 'create handles record url' do
    url_data = OpenStruct.new(deposition?: false, record?: true, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: '11', deposition_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    record = OpenStruct.new(title: 'rec', concept_id: 'cid', version: 'v1')
    records_service = mock('records')
    records_service.expects(:find_record).with('11').returns(record)
    Zenodo::RecordService.stubs(:new).returns(records_service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://zenodo.org/record/11')
    assert result.success?
    assert_equal 'cid', result.resource.metadata[:concept_id]
  end
end

