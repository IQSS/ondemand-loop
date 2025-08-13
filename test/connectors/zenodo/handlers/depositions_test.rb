require 'test_helper'

class Zenodo::Handlers::DepositionsTest < ActiveSupport::TestCase
  def setup
    @explorer = Zenodo::Handlers::Depositions.new('10')
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
    assert_includes @explorer.params_schema, :project_id
    assert @explorer.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end

  test 'show loads deposition using repo db api key' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    service.expects(:find_deposition).with('10').returns(:deposition)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)

    result = @explorer.show(repo_url: @repo_url)
    assert result.success?
  end

  test 'show returns error when api key missing' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: nil))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    result = @explorer.show(repo_url: @repo_url)
    refute result.success?
    assert_equal I18n.t('zenodo.depositions.message_api_key_required'), result.message[:alert]
  end

  test 'show returns error when deposition not found' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(nil)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)
    result = @explorer.show(repo_url: @repo_url)
    refute result.success?
  end

  test 'create downloads files into project' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    service.expects(:find_deposition).with('10').returns(:deposition)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)

    Project.stubs(:find).with('1').returns(nil)
    project = mock('project')
    project.stubs(:save).returns(true)
    project.stubs(:name).returns('Proj')

    file = mock('file')
    file.stubs(:valid?).returns(true)
    file.stubs(:save).returns(true)

    proj_service = mock('proj_service')
    proj_service.expects(:initialize_project).returns(project)
    proj_service.expects(:create_files_from_deposition).with(project, :deposition, ['f1']).returns([file])
    Zenodo::ProjectService.expects(:new).with('https://zenodo.org').returns(proj_service)

    result = @explorer.create(repo_url: @repo_url, file_ids: ['f1'], project_id: '1')
    assert result.success?
  end
end
