require "test_helper"

class UploadStatusControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    UploadBundle.stubs(:metadata_root_directory).returns(@tmp_dir)
    UploadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index on empty disk" do
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    get upload_status_url
    assert_response :success
  end

  test "should get index on disk with data" do
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    populate
    get upload_status_url
    assert_response :success
  end

  test "files renders partial" do
    UploadStatusController.any_instance.stubs(:upload_status).returns(OpenStruct.new(idle?: true))
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)
    get upload_status_files_url
    assert_response :success
  end

  test "files include view events button" do
    UploadStatusController.any_instance.stubs(:upload_status).returns(OpenStruct.new(idle?: true))
    ScriptLauncher.any_instance.stubs(:launch_script).returns(true)

    parsed_url = URI.parse("http://localhost:3000")
    service = Dataverse::ProjectService.new(parsed_url.to_s)
    project = service.initialize_project
    project.save

    upload_bundle = create_upload_bundle(project)
    upload_bundle.save
    file = create_upload_file(project, upload_bundle)
    file.save

    Upload::UploadFilesProvider.any_instance
                               .stubs(:recent_files)
                               .returns([OpenStruct.new(file: file,
                                                        project: project,
                                                        upload_bundle: upload_bundle)])

    get upload_status_files_url
    assert_response :success
    assert_select 'button.status-badge-button[data-modal-url-value=?]',
                  widgets_path('events', project_id: project.id,
                                        entity_type: 'upload_file',
                                        entity_id: file.id)
  end

  private

  def populate
    parsed_url = URI.parse("http://localhost:3000")
    service = Dataverse::ProjectService.new(parsed_url.to_s)
    project = service.initialize_project
    project.save

    upload_bundle = create_upload_bundle(project)
    upload_bundle.save
    upload_file = create_upload_file(project, upload_bundle)
    upload_file.save
  end
end
