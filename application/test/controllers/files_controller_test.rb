require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project_id = "test_project"
    @file_id = "file_123"
    @file = mock("DownloadFile")
    @now = Time.current

    # Stub now from DateTimeCommon if needed
    FilesController.any_instance.stubs(:now).returns(@now)
  end

  test "should return not_found if file is nil" do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    post downloads_file_cancel_url(project_id: @project_id, file_id: @file_id)
    assert_response :not_found
    assert_match "file not found", @response.body
  end

  test "should cancel download if file is downloading and command fails" do
    @file.stubs(:status).returns(FileStatus.get("downloading"))
    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 500))
    Download::Command::DownloadCommandClient.stubs(:new).returns(mock_client)

    post downloads_file_cancel_url(project_id: @project_id, file_id: @file_id)

    assert_response :not_found
  end

  test "should cancel and update file if downloading and command succeeds" do
    @file.stubs(:status).returns(FileStatus.get("downloading"))
    @file.expects(:update).with(start_date: @now, end_date: @now, status: FileStatus::CANCELLED)

    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 200))
    Download::Command::DownloadCommandClient.stubs(:new).returns(mock_client)

    post downloads_file_cancel_url(project_id: @project_id, file_id: @file_id)

    assert_response :no_content
  end

  test "should update and save file if not downloading" do
    @file.stubs(:status).returns(FileStatus.get("success"))
    @file.expects(:update).with(start_date: @now, end_date: @now, status: FileStatus::CANCELLED)

    DownloadFile.stubs(:find).returns(@file)

    post downloads_file_cancel_url(project_id: @project_id, file_id: @file_id)

    assert_response :no_content
  end
end
