require 'test_helper'

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @new_id = SecureRandom.uuid.to_s
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: ConnectorType::DATAVERSE))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    # Mock RepoRegistry for service initialization
    repo_info = mock('repo_info')
    metadata = mock('metadata')
    metadata.stubs(:auth_key).returns('test_api_key')
    repo_info.stubs(:metadata).returns(metadata)
    RepoRegistry.stubs(:repo_db).returns(mock('repo_db').tap { |db| db.stubs(:get).returns(repo_info) })
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def dataset_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
  end

  def dataset_incomplete_json_no_data
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_data.json'))
  end

  def dataset_incomplete_json_no_metadata_blocks
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_metadata_blocks.json'))
  end

  def dataset_incomplete_json_no_license
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_license.json'))
  end

  def files_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
  end

  def files_incomplete_no_data_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data.json'))
  end

  def files_incomplete_no_data_file_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data_file.json'))
  end

  # URL validation tests
  test 'should redirect if dataverse url is not supported' do
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: nil))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    get view_dataverse_dataset_url('invalid.host', 'id1')

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.url_not_supported', dataverse_url: 'https://invalid.host'), flash[:alert]
  end

  # Dataset not found tests
  test 'should redirect to root path after not finding a dataset' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_not_found',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect back to internal referer when dataset is not found' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    internal_referer = view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataset_not_found',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect back to internal referer when dataset is not found with script name' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    internal_referer = '/pun/sys/loop' + view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataset_not_found',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to root path when referer is external and dataset is not found' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: {HTTP_REFERER: 'http://external.com/another/page'}, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_not_found',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  # Service error tests
  test 'should redirect to root path after raising exception' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises('error')
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataverse_service_error',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to internal referrer after raising exception' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises('error')
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    internal_referer = view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataverse_service_error',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to internal referrer after raising exception with script name' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises('error')
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    internal_referer = '/pun/sys/loop' + view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataverse_service_error',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to root path after raising exception coming from external referrer' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises('error')
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { HTTP_REFERER: 'http://external.com/another/page'}, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataverse_service_error',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  # Authorization tests
  test 'should redirect to root path after raising Unauthorized exception' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_requires_authorization',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to internal referrer after raising Unauthorized exception' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    internal_referer = view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataset_requires_authorization',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to internal referrer after raising Unauthorized exception with script name' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    internal_referer = '/pun/sys/loop' + view_dataverse_landing_path.to_s
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { 'HTTP_REFERER' => internal_referer }, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to internal_referer
    assert_equal I18n.t('dataverse.datasets.dataset_requires_authorization',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  test 'should redirect to root path after raising Unauthorized exception coming from external referrer' do
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, 'random_id'), headers: { HTTP_REFERER: 'http://external.com/another/page'}, env: { 'SCRIPT_NAME' => '/pun/sys/loop' }
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_requires_authorization',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: nil), flash[:alert]
  end

  # Files-specific authorization tests
  test 'should redirect to root path after raising Unauthorized exception only in files page' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_files_endpoint_requires_authorization',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: dataset.version,
                        page: 1), flash[:alert]
  end

  test 'should redirect to root path when files not found' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataset_files_not_found',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: dataset.version,
                        page: 1), flash[:alert]
  end

  test 'should redirect to root path when files service raises exception' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(StandardError.new('Files error'))
    get view_dataverse_dataset_url(@new_id, 'random_id')
    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.dataverse_service_error_searching_files',
                        dataverse_url: "https://#{@new_id}",
                        persistent_id: 'random_id',
                        version: dataset.version,
                        page: 1), flash[:alert]
  end

  # Successful display tests
  test 'should display the dataset view with the file' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, 'doi:10.5072/FK2/GCN7US')
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
    assert_select "form#dataset-download-files-form input[type=hidden][name=version][value='2.0']", 1
    assert_select "form#dataset-search-form input[type=hidden][name=version][value='2.0']", 1
  end

  test 'should display the dataset incomplete with no data' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_incomplete_json_no_data)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_incomplete_no_data_json)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, 'doi:10.5072/FK2/LLIZ6Q')
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 0
    assert_select "form#dataset-download-files-form input[type=hidden][name=version][value='']", 1
    assert_select "form#dataset-search-form input[type=hidden][name=version][value='']", 1
  end

  test 'should display the dataset incomplete with no data file' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_incomplete_json_no_data)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_incomplete_no_data_file_json)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, 'doi:10.5072/FK2/LLIZ6Q')
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
    assert_select "form#dataset-download-files-form input[type=hidden][name=version][value='']", 1
    assert_select "form#dataset-search-form input[type=hidden][name=version][value='']", 1
  end

  test "dataset view shows active project button text when project active" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    user_settings_mock = mock("UserSettings")
    user_settings_mock.stubs(:user_settings).returns(OpenStruct.new(active_project: "proj"))
    Current.stubs(:settings).returns(user_settings_mock)

    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    label = I18n.t('dataverse.datasets.dataset_files.button_add_files_active_project_text')
    title = I18n.t('dataverse.datasets.dataset_files.button_add_files_active_project_title')
    assert_select "input[type=submit][value='#{label}'][title='#{title}']", 1
  end

  test "dataset view shows new project button text when no active project" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    user_settings_mock = mock("UserSettings")
    user_settings_mock.stubs(:user_settings).returns(OpenStruct.new(active_project: nil))
    Current.stubs(:settings).returns(user_settings_mock)

    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    label = I18n.t('dataverse.datasets.dataset_files.button_add_files_new_project_text')
    title = I18n.t('dataverse.datasets.dataset_files.button_add_files_new_project_title')
    assert_select "input[type=submit][value='#{label}'][title='#{title}']", 1
  end

  test 'should handle search query parameter with sanitization' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)

    get view_dataverse_dataset_url(@new_id, 'doi:10.5072/FK2/GCN7US'), params: { query: "<script>alert('xss')</script>test" }

    assert_response :success
  end

  test 'should handle pagination parameter' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)

    get view_dataverse_dataset_url(@new_id, 'doi:10.5072/FK2/GCN7US'), params: { page: 2 }

    assert_response :success
  end

  # Download action tests
  test 'should redirect if project fails to save' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    project = Project.new
    project.stubs(:save).returns(false)
    project.errors.add(:base, 'Project save failed')

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_project).returns(project)

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['123'],
      project_id: nil,
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.error_generating_project',
                        errors: 'Project save failed'), flash[:alert]
  end

  test 'should redirect if any download file is invalid' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: 'Test Project')
    project.stubs(:save).returns(true)

    invalid_file = DownloadFile.new(filename: 'bad_file.txt')
    invalid_file.stubs(:valid?).returns(false)
    invalid_file.stubs(:to_s).returns('DownloadFile: bad_file.txt')
    invalid_file.errors.add(:base, 'Invalid file')
    valid_file = DownloadFile.new(filename: 'good_file.txt')
    valid_file.stubs(:valid?).returns(true)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    Dataverse::ProjectService.any_instance.stubs(:initialize_download_files).returns([valid_file, invalid_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['1', '2'],
      project_id: nil,
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.invalid_file_in_selection',
                        filename: 'bad_file.txt',
                        errors: 'Invalid file'), flash[:alert]
  end

  test 'should redirect if download file save fails' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: 'Test Project')
    project.stubs(:save).returns(true)

    valid_file = DownloadFile.new(filename: 'file.txt')
    valid_file.stubs(:valid?).returns(true)
    valid_file.stubs(:save).returns(false)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    Dataverse::ProjectService.any_instance.stubs(:initialize_download_files).returns([valid_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['1'],
      project_id: nil,
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.error_generating_the_download_file'), flash[:alert]
  end

  test 'should redirect with notice if download files are saved successfully' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    project = Project.new(name: 'Test Project')
    project.stubs(:id).returns('1')
    project.stubs(:save).returns(true)

    file1 = DownloadFile.new(filename: 'file1.txt')
    file1.stubs(:valid?).returns(true)
    file1.stubs(:save).returns(true)

    file2 = DownloadFile.new(filename: 'file2.txt')
    file2.stubs(:valid?).returns(true)
    file2.stubs(:save).returns(true)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    Dataverse::ProjectService.any_instance.stubs(:initialize_download_files).returns([file1, file2])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['1', '2'],
      project_id: nil,
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.files_added_to_project',
                        project_name: 'Test Project'), flash[:notice]
  end

  test 'should use existing project when project_id is provided' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    existing_project = Project.new(name: 'Existing Project', id: '123')
    Project.stubs(:find).with('').returns(nil)
    Project.stubs(:find).with('123').returns(existing_project)

    download_file = DownloadFile.new(filename: 'test_file.txt')
    download_file.stubs(:valid?).returns(true)
    download_file.stubs(:save).returns(true)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_download_files).returns([download_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['1'],
      project_id: '123',
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.files_added_to_project',
                        project_name: 'Existing Project'), flash[:notice]
  end

  test 'should handle project_id parameter being nil and create new project' do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)

    Project.stubs(:find).with('').returns(nil)
    Project.stubs(:find).with(nil).returns(nil)

    new_project = Project.new(name: 'New Project')
    new_project.stubs(:save).returns(true)

    download_file = DownloadFile.new(filename: 'test_file.txt')
    download_file.stubs(:valid?).returns(true)
    download_file.stubs(:save).returns(true)

    Dataverse::DatasetService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DatasetService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    Dataverse::ProjectService.any_instance.stubs(:initialize_project).returns(new_project)
    Dataverse::ProjectService.any_instance.stubs(:initialize_download_files).returns([download_file])

    post download_dataverse_dataset_files_url, params: {
      file_ids: ['1'],
      project_id: nil,
      dataverse_url: 'https://example.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      page: 1,
      version: '2.0'
    }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.datasets.download.files_added_to_project',
                        project_name: 'New Project'), flash[:notice]
  end

end
