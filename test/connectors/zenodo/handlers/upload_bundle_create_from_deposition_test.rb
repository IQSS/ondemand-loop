require 'test_helper'

class Zenodo::Handlers::UploadBundleCreateFromDepositionTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Handlers::UploadBundleCreateFromDeposition.new
    ::Configuration.repo_history.stubs(:add_repo)
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'create handles deposition with auth key' do
    url_data = OpenStruct.new(deposition?: true, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', deposition_id: '10', record_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    dep = OpenStruct.new(title: 'title', bucket_url: 'b', draft?: false, version: '1')
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

  test 'deposition not found returns error' do
    url_data = OpenStruct.new(deposition?: true, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', deposition_id: '10', record_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    service.expects(:find_deposition).with('10').returns(nil)
    Zenodo::DepositionService.stubs(:new).returns(service)

    result = @action.create(@project, object_url: 'https://zenodo.org/deposit/10')
    refute result.success?
  end

  test 'create adds repo history' do
    url_data = OpenStruct.new(deposition?: true, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', deposition_id: '10', record_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    dep = OpenStruct.new(title: 'Depo', bucket_url: 'b', draft?: true, version: 'draft')
    service = mock('service')
    service.stubs(:find_deposition).with('10').returns(dep)
    Zenodo::DepositionService.stubs(:new).returns(service)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)

    ::Configuration.repo_history.expects(:add_repo).with('https://zenodo.org/deposit/10', ConnectorType::ZENODO, title: 'Depo', note: 'draft')

    @action.create(@project, object_url: 'https://zenodo.org/deposit/10')
  end
end

