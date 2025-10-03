require "test_helper"

class DownloadFilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project_id = "test_project"
    @file_id = "file_123"
    @file = DownloadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.type = ConnectorType::DATAVERSE
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
    end
  end

  test "cancel should redirect with error message when file is nil" do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'not found', flash[:alert]
    assert_match @project_id, flash[:alert]
    assert_match @file_id, flash[:alert]
  end

  test "cancel should redirect with error message when downloading and command fails" do
    @file.stubs(:status).returns(FileStatus::DOWNLOADING)
    @file.stubs(:filename).returns('filename_test')
    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 500))
    Command::CommandClient.stubs(:new).returns(mock_client)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Could not cancel download', flash[:alert]
    assert_match 'filename_test', flash[:alert]
  end

  test "cancel should redirect with message and update file if downloading and command succeeds" do
    @file.stubs(:status).returns(FileStatus::DOWNLOADING)
    @file.stubs(:filename).returns('filename_test')
    @file.expects(:update).with(status: FileStatus::CANCELLED).returns(true)

    DownloadFile.stubs(:find).returns(@file)

    mock_client = mock("DownloadCommandClient")
    mock_client.expects(:request).returns(OpenStruct.new(status: 200))
    Command::CommandClient.stubs(:new).returns(mock_client)

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'cancelled', flash[:notice]
    assert_match 'filename_test', flash[:notice]
  end

  test "cancel should redirect with message and save file if not downloading" do
    @file.stubs(:status).returns(FileStatus::SUCCESS)
    @file.stubs(:filename).returns('filename_test')
    @file.expects(:update).with(status: FileStatus::CANCELLED).returns(true)

    DownloadFile.stubs(:find).returns(@file)
    DownloadFilesController.any_instance.expects(:log_download_file_event).with(
      @file,
      message: 'events.download_file.cancel_completed',
      metadata: { previous_status: 'success' }
    )

    post cancel_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'cancelled', flash[:notice]
    assert_match 'filename_test', flash[:notice]
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
    DownloadFilesController.any_instance.expects(:log_download_file_event).with(
      @file,
      message: 'events.download_file.deleted'
    )

    delete project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'deleted', flash[:notice]
    assert_match 'file.zip', flash[:notice]
  end

  test 'retry should redirect with alert if file is nil' do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    post retry_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'not found for project', flash[:alert]
  end

  test 'retry should redirect with alert if file status is not retryable' do
    @file.stubs(:status).returns(FileStatus::SUCCESS)
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(@file)

    post retry_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'cannot be moved back to the pending queue', flash[:alert]
  end

  test 'retry should change status and redirect for retryable status' do
    @file.stubs(:status).returns(FileStatus::ERROR)
    @file.expects(:update).with(status: FileStatus::PENDING).returns(true)
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(@file)

    post retry_project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'moved back to the pending queue', flash[:notice]
  end
end
