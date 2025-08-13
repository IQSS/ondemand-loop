require "test_helper"

class DownloadFilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project_id = "test_project"
    @file_id = "file_123"
    @file = mock("DownloadFile")
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

    delete project_download_file_url(project_id: @project_id, id: @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'deleted', flash[:notice]
    assert_match 'file.zip', flash[:notice]
  end

  test 'update should redirect with alert if file is nil' do
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(nil)

    patch project_download_file_url(project_id: @project_id, id: @file_id), params: { state: 'pending' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'not found for project', flash[:alert]
  end

  test 'update should change status and redirect' do
    @file.stubs(:filename).returns('file.txt')
    @file.expects(:update).with(status: FileStatus::PENDING).returns(true)
    DownloadFile.stubs(:find).with(@project_id, @file_id).returns(@file)

    patch project_download_file_url(project_id: @project_id, id: @file_id), params: { state: 'pending' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'file.txt', flash[:notice]
  end
end
