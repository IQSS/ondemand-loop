require 'test_helper'

class Zenodo::Actions::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Actions::UploadBundleCreate.new
  end

  test 'url not deposition returns error' do
    result = @action.create(@project, object_url: 'http://example.com')
    refute result.success?
  end

  test 'create handles deposition with auth key' do
    url_data = OpenStruct.new(deposition?: true, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', deposition_id: '10')
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    dep = OpenStruct.new(title: 'title', bucket_url: 'b', draft?: false)
    service = mock('service')
    service.stubs(:find_deposition).with('10').returns(dep)
    Zenodo::DepositionService.stubs(:new).returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://zenodo.org/deposit/10')
    assert result.success?
    assert_equal 'bundle', result.resource.id
    assert_equal 'title', result.resource.metadata[:title]
  end

  test 'record not found returns error' do
    url_data = OpenStruct.new(deposition?: true, record?: true, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: '99')
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: nil))
    RepoRegistry.repo_db.stubs(:get).returns(repo_info)

    records_service = mock('records')
    records_service.expects(:find_record).with('99').returns(nil)
    Zenodo::RecordService.stubs(:new).returns(records_service)

    result = @action.create(@project, object_url: 'https://zenodo.org/record/99')
    refute result.success?
  end
end
