require "test_helper"

class DownloadFilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project_id = "test_project"
    @file_id = "file_123"
    @file = mock("DownloadFile")
    @now = Time.current

    # Stub now from DateTimeCommon if needed
    DownloadFilesController.any_instance.stubs(:now).returns(@now)
  end

  test "cancel should return not_found if file is nil" do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_response :not_found
    assert_match "not found for project", @response.body
  end

  test "cancel should return 404 if file is downloading and command fails" do
    @file.stubs(:status).returns(FileStatus::DOWNLOADING)
    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 500))
    Command::CommandClient.stubs(:new).returns(mock_client)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)

    assert_response :not_found
  end

  test "cancel should return 200 and update file if downloading and command succeeds" do
    @file.stubs(:status).returns(FileStatus::DOWNLOADING)
    @file.expects(:update).with(start_date: @now, end_date: @now, status: FileStatus::CANCELLED)

    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 200))
    Command::CommandClient.stubs(:new).returns(mock_client)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)

    assert_response :no_content
  end

  test "cancel should return 200 and save file if not downloading" do
    @file.stubs(:status).returns(FileStatus::SUCCESS)
    @file.expects(:update).with(start_date: @now, end_date: @now, status: FileStatus::CANCELLED)

    DownloadFile.stubs(:find).returns(@file)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)

    assert_response :no_content
  end

  test 'destroy should redirect with alert if file is nil' do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    delete project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'not found for project', flash[:alert]
  end

  test 'destroy should redirect with alert if file is downloading' do
    @file.stubs(:status).returns(FileStatus::DOWNLOADING)
    @file.stubs(:filename).returns('file.zip')
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(@file)

    delete project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'file.zip', flash[:alert]
    assert_match 'cannot be deleted', flash[:alert]
  end

  test 'destroy should delete file and redirect with notice if not downloading' do
    @file.stubs(:status).returns(FileStatus::SUCCESS)
    @file.stubs(:filename).returns('file.zip')
    @file.expects(:destroy)
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(@file)

    delete project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'deleted', flash[:notice]
    assert_match 'file.zip', flash[:notice]
  end
end
