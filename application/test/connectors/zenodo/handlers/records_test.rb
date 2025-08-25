require 'test_helper'

class Zenodo::Handlers::RecordsTest < ActiveSupport::TestCase
  def setup
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
    @explorer = Zenodo::Handlers::Records.new('123')
    @settings = mock('settings')
    @settings.stubs(:update_user_settings)
    Current.stubs(:settings).returns(@settings)
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
    assert_includes @explorer.params_schema, :project_id
    assert @explorer.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end

  test 'show renders dataset when found' do
    service = mock('service')
    dataset = OpenStruct.new(title: 'Record Title', draft?: false, version: 'published')
    service.expects(:find_record).with('123').returns(dataset)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    url = Zenodo::Concerns::ZenodoUrlBuilder.build_record_url('https://zenodo.org', '123')
    RepoRegistry.repo_history.expects(:add_repo).with(
      url,
      ConnectorType::ZENODO,
      title: 'Record Title',
      note: 'published'
    )
    res = @explorer.show(repo_url: @repo_url)
    assert res.success?
    assert_equal dataset, res.locals[:dataset]
    assert_equal 'Record Title', res.locals[:dataset_title]
    assert_equal url, res.locals[:external_zenodo_url]
    assert_equal dataset, res.resource
  end

  test 'show returns error when dataset missing' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(nil)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.show(repo_url: @repo_url)
    refute res.success?
  end

  test 'create initializes project and files' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(:dataset)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)

    Project.stubs(:find).with('1').returns(nil)
    project = mock('project')
    project.expects(:save).returns(true)
    project.stubs(:name).returns('Proj')
    project.stubs(:id).returns(1)

    file = mock('file')
    file.stubs(:valid?).returns(true)
    file.stubs(:save).returns(true)

    proj_service = mock('proj_service')
    proj_service.expects(:initialize_project).returns(project)
    proj_service.expects(:create_files_from_record).with(project, :dataset, ['f1']).returns([file])
    Zenodo::ProjectService.expects(:new).with('https://zenodo.org').returns(proj_service)

    @settings.expects(:update_user_settings).with({ active_project: project.id.to_s })
    res = @explorer.create(repo_url: @repo_url, file_ids: ['f1'], project_id: '1')
    assert res.success?
  end

  test 'create returns error when dataset not found' do
    service = mock('service')
    service.expects(:find_record).with('123').returns(nil)
    Zenodo::RecordService.expects(:new).with('https://zenodo.org').returns(service)
    res = @explorer.create(repo_url: @repo_url, file_ids: [], project_id: '1')
    refute res.success?
  end
end
