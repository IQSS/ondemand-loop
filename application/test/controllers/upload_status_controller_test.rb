require "test_helper"

class UploadStatusControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    UploadBatch.stubs(:metadata_root_directory).returns(@tmp_dir)
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

  private

  def populate
    parsed_url = URI.parse("http://localhost:3000")
    service = Dataverse::ProjectService.new(parsed_url.to_s)
    project = service.initialize_project
    project.save

    upload_batch = create_upload_batch(project)
    upload_batch.save
    upload_file = create_upload_file(project, upload_batch)
    upload_file.save
  end
end
