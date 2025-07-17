require "test_helper"

class DownloadStatusControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index on empty disk" do
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    get download_status_url
    assert_response :success
  end

  test "should get index on disk with data" do
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    populate
    get download_status_url
    assert_response :success
  end

  test "files renders partial" do
    DownloadStatusController.any_instance.stubs(:download_status).returns(OpenStruct.new(idle?: true))
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    get download_status_files_url
    assert_response :success
  end

  private

  def populate
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
    dataset = Dataverse::DatasetVersionResponse.new(valid_json)
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
    files_page = Dataverse::DatasetFilesResponse.new(valid_json)
    file_ids = [4,5]

    parsed_url = URI.parse("http://localhost:3000")
    service = Dataverse::ProjectService.new(parsed_url.to_s)
    project = service.initialize_project
    project.save

    files = service.initialize_download_files(project, dataset.data.dataset_persistent_id, dataset, files_page, file_ids)
    files.each do |download_file|
      download_file.save
    end
  end
end
