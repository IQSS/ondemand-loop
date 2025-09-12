require 'test_helper'

class Zenodo::Handlers::DepositionsTest < ActiveSupport::TestCase
  def setup
    @explorer = Zenodo::Handlers::Depositions.new('10')
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
    @settings = mock('settings')
    @settings.stubs(:update_user_settings)
    Current.stubs(:settings).returns(@settings)
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
    assert_includes @explorer.params_schema, :project_id
    assert @explorer.params_schema.any? { |p| p.is_a?(Hash) && p.key?(:file_ids) }
  end

  test 'show loads deposition using repo db api key' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    dataset = OpenStruct.new(title: 'Deposition Title', draft?: true, version: 'draft')
    service.expects(:find_deposition).with('10').returns(dataset)
    Zenodo::DepositionService.expects(:new).with(zenodo_url: 'https://zenodo.org', api_key: 'KEY').returns(service)

    url = Zenodo::Concerns::ZenodoUrlBuilder.build_deposition_url('https://zenodo.org', '10')
    ::Configuration.repo_history.expects(:add_repo).with(
      url,
      ConnectorType::ZENODO,
      title: 'Deposition Title',
      note: 'draft'
    )
    result = @explorer.show(repo_url: @repo_url)
    assert result.success?
    assert_equal dataset, result.locals[:dataset]
    assert_equal 'Deposition Title', result.locals[:dataset_title]
    assert_equal url, result.locals[:external_zenodo_url]
    assert_equal dataset, result.resource
  end

  test 'show returns error when api key missing' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: nil))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    result = @explorer.show(repo_url: @repo_url)
    refute result.success?
    assert_equal I18n.t('zenodo.depositions.message_api_key_required'), result.message[:alert]
  end

  test 'show returns error when deposition not found' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)
    service = mock('service')
    service.expects(:find_deposition).with('10').returns(nil)
    Zenodo::DepositionService.expects(:new).with(zenodo_url: 'https://zenodo.org', api_key: 'KEY').returns(service)
    result = @explorer.show(repo_url: @repo_url)
    refute result.success?
  end

  test 'create downloads files into project' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    ::Configuration.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    service.expects(:find_deposition).with('10').returns(:dataset)
    Zenodo::DepositionService.expects(:new).with(zenodo_url: 'https://zenodo.org', api_key: 'KEY').returns(service)

    Project.stubs(:find).with('1').returns(nil)
    project = mock('project')
    project.stubs(:save).returns(true)
    project.stubs(:name).returns('Proj')
    project.stubs(:id).returns('1')

    file = mock('file')
    file.stubs(:valid?).returns(true)
    file.stubs(:save).returns(true)

    proj_service = mock('proj_service')
    proj_service.expects(:initialize_project).returns(project)
    proj_service.expects(:create_files_from_deposition).with(project, :dataset, ['f1']).returns([file])
    Zenodo::ProjectService.expects(:new).with(zenodo_url: 'https://zenodo.org').returns(proj_service)

    @settings.expects(:update_user_settings).with({ active_project: project.id.to_s })
    result = @explorer.create(repo_url: @repo_url, file_ids: ['f1'], project_id: '1')
    assert result.success?
  end
end
