require 'test_helper'

class Zenodo::Handlers::UploadBundleCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Handlers::UploadBundleCreate.new
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'create handles generic zenodo url' do
    url_data = OpenStruct.new(deposition?: false, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: nil, deposition_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://zenodo.org/about')
    assert result.success?
    assert_equal 'https://zenodo.org', result.resource.metadata[:zenodo_url]
    assert_nil result.resource.metadata[:record_id]
    assert_nil result.resource.metadata[:deposition_id]
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
    url_data = OpenStruct.new(deposition?: false, record?: true, domain: 'zenodo.org',
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

  test 'create handles record url' do
    url_data = OpenStruct.new(deposition?: false, record?: true, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: '11')
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    RepoRegistry.repo_db.stubs(:get).returns(OpenStruct.new(metadata: OpenStruct.new(auth_key: nil)))

    record = OpenStruct.new(title: 'rec', concept_id: 'cid')
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
