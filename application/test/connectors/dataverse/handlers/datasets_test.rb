require 'test_helper'

class Dataverse::Handlers::DatasetsTest < ActiveSupport::TestCase
  def setup
    @repo_url = Repo::RepoUrl.parse('https://dataverse.org')
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'key'))
    RepoRegistry.stubs(:repo_db).returns(stub(get: repo_info))
    @explorer = Dataverse::Handlers::Datasets.new('pid')
    @settings = mock('settings')
    @settings.stubs(:update_user_settings)
    Current.stubs(:settings).returns(@settings)
  end

  test 'params schema includes expected keys' do
    [:repo_url, :version, :page, :query, :project_id].each do |key|
      assert_includes @explorer.params_schema, key
    end
    assert @explorer.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end

  test 'show renders dataset when found' do
    dataset = OpenStruct.new(version: '1', title: 'Title', data: OpenStruct.new(dataset_persistent_id: 'pid'))
    files_page = OpenStruct.new(total_count: 0, page: 1, query: nil, files: [])
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(dataset)
    service.expects(:search_dataset_files_by_persistent_id).with('pid', version: '1', page: 1, query: nil).returns(files_page)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    expected_url = Dataverse::Concerns::DataverseUrlBuilder.build_dataset_url('https://dataverse.org', 'pid', version: '1')
    RepoRegistry.repo_history.expects(:add_repo).with(
      expected_url,
      ConnectorType::DATAVERSE,
      title: 'Title',
      note: '1'
    )

    res = @explorer.show(repo_url: @repo_url)
    assert res.success?
    assert_equal dataset, res.locals[:dataset]
    assert_equal files_page, res.locals[:files_page]
    assert_equal dataset, res.resource
  end

  test 'show returns error when dataset missing' do
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    refute res.success?
  end

  test 'show returns error when files not found' do
    dataset = OpenStruct.new(version: '1', data: OpenStruct.new(dataset_persistent_id: 'pid'))
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(dataset)
    service.expects(:search_dataset_files_by_persistent_id).with('pid', version: '1', page: 1, query: nil).returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    refute res.success?
  end

  test 'show handles unauthorized exception' do
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil)
           .raises(Dataverse::DatasetService::UnauthorizedException.new)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    refute res.success?
  end

  test 'create initializes project and files' do
    dataset = OpenStruct.new(version: '1', data: OpenStruct.new(dataset_persistent_id: 'different', parents: []))
    files_page = OpenStruct.new(total_count: 0, page: 1, query: nil, files: [])
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(dataset)
    service.expects(:search_dataset_files_by_persistent_id).with('pid', version: '1', page: 1, query: nil).returns(files_page)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)

    Project.stubs(:find).with('1').returns(nil)
    project = mock('project')
    project.expects(:save).returns(true)
    project.stubs(:name).returns('Proj')
    project.stubs(:id).returns('1')

    file = mock('file')
    file.stubs(:valid?).returns(true)
    file.stubs(:save).returns(true)

    proj_service = mock('proj_service')
    proj_service.expects(:initialize_project).returns(project)
    proj_service.expects(:initialize_download_files).with(project, 'pid', dataset, files_page, ['f1']).returns([file])
    Dataverse::ProjectService.expects(:new).with('https://dataverse.org').returns(proj_service)

    @settings.expects(:update_user_settings).with({ active_project: '1' })
    res = @explorer.create(repo_url: @repo_url, file_ids: ['f1'], project_id: '1')
    assert res.success?
  end

  test 'create returns error when dataset not found' do
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.create(repo_url: @repo_url, file_ids: [], project_id: '1')
    refute res.success?
  end

  test 'create returns error when files not found' do
    dataset = OpenStruct.new(version: '1', data: OpenStruct.new(dataset_persistent_id: 'pid', parents: []))
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil).returns(dataset)
    service.expects(:search_dataset_files_by_persistent_id).with('pid', version: '1', page: 1, query: nil).returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.create(repo_url: @repo_url, file_ids: [], project_id: '1')
    refute res.success?
  end

  test 'create handles unauthorized exception' do
    service = mock('service')
    service.expects(:find_dataset_version_by_persistent_id).with('pid', version: nil)
           .raises(Dataverse::DatasetService::UnauthorizedException.new)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)
    res = @explorer.create(repo_url: @repo_url, file_ids: [], project_id: '1')
    refute res.success?
  end
end
