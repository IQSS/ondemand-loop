require 'test_helper'

class UploadFilesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @project_id = 'test-project'
    @upload_bundle_id = 'test-collection'
    @file_id = 'file-123'
    @test_path = Rails.root.join('test/fixtures/files/sample.txt').to_s
  end

  test 'index should return success' do
    upload_bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(upload_bundle)

    get project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id)

    assert_response :ok
  end

  test 'create should return not found if upload batch does not exist' do
    UploadBundle.stubs(:find).returns(nil)

    post project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id), params: {
      path: @test_path
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload bundle not found', flash[:alert]
  end

  test 'create should return bad request if file is invalid' do
    upload_bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(upload_bundle)

    UploadFilesController.any_instance.stubs(:list_files)
                         .returns([OpenStruct.new(fullpath: @test_path, filename: 'invalid.txt', size: 2.gigabytes)])

    post project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id), params: {
      path: @test_path
    }

    assert_response :bad_request
    assert_match /Invalid file in selection/, @response.body
  end

  test 'create should create and return ok if files are valid' do
    upload_bundle = create_upload_bundle(create_project)
    upload_bundle.id = @upload_bundle_id
    upload_bundle.project_id = @project_id
    UploadBundle.stubs(:find).returns(upload_bundle)

    UploadFilesController.any_instance.stubs(:list_files)
                         .returns([OpenStruct.new(fullpath: @test_path, filename: 'valid.txt', size: 456)])

    UploadFile.any_instance.stubs(:valid?).returns(true)
    UploadFile.any_instance.stubs(:save).returns(true)
    UploadFile.any_instance.stubs(:filename).returns('valid.txt')

    post project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id), params: {
      path: @test_path
    }

    assert_response :ok
    assert_match /File added: valid.txt/, @response.body
  end

  test 'delete should redirect with alert if file is nil' do
    UploadFile.stubs(:find).with(@project_id, @upload_bundle_id, @file_id).returns(nil)

    delete project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'not found for project', flash[:alert]
  end

  test 'destroy should delete upload file and redirect when not uploading' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.filename = 'delete.txt'
      file.status = FileStatus::PENDING
    end
    file.expects(:destroy)

    UploadFile.stubs(:find).with(@project_id, @upload_bundle_id, @file_id).returns(file)
    UploadFilesController.any_instance.expects(:log_upload_file_event).with(
      file,
      message: 'events.upload_file.deleted'
    )

    delete project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)

    assert_redirected_to root_path
    assert_includes flash[:notice], 'Upload file removed from bundle'
    assert_includes flash[:notice], 'delete.txt'
  end

  test 'destroy should return error when file is uploading' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.filename = 'delete.txt'
      file.status = FileStatus::UPLOADING
    end
    file.expects(:destroy).never

    UploadFile.stubs(:find).with(@project_id, @upload_bundle_id, @file_id).returns(file)

    delete project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)

    assert_redirected_to root_path
    assert_includes flash[:alert], 'cannot be deleted'
    assert_includes flash[:alert], 'delete.txt'
  end

  test 'cancel should redirect with error message when file is missing on cancel' do
    UploadFile.stubs(:find).returns(nil)

    post cancel_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match @file_id, flash[:alert]
    assert_match 'not found', flash[:alert]
  end

  test 'cancel should cancel uploading file and return no content' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.upload_bundle_id = @upload_bundle_id
      file.filename = 'cancel.txt'
      file.status = FileStatus::UPLOADING
    end
    file.expects(:update).with(status: FileStatus::CANCELLED).returns(true)

    UploadFile.stubs(:find).returns(file)

    mock_response = mock
    mock_response.stubs(:status).returns(200)

    Command::CommandClient.any_instance.stubs(:request).returns(mock_response)
    UploadFilesController.any_instance.expects(:log_upload_file_event).with(
      file,
      message: 'events.upload_file.cancel_completed',
      metadata: { previous_status: 'uploading' }
    )

    post cancel_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload cancelled', flash[:notice]
    assert_match 'cancel.txt', flash[:notice]
  end

  test 'cancel should log event when file is not uploading' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.upload_bundle_id = @upload_bundle_id
      file.filename = 'done.txt'
      file.status = FileStatus::SUCCESS
    end
    file.expects(:update).with(status: FileStatus::CANCELLED).returns(true)

    UploadFile.stubs(:find).returns(file)

    UploadFilesController.any_instance.expects(:log_upload_file_event).with(
      file,
      message: 'events.upload_file.cancel_completed',
      metadata: { previous_status: 'success' }
    )

    post cancel_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload cancelled', flash[:notice]
    assert_match 'done.txt', flash[:notice]
  end

  test 'retry should redirect with error message when file is missing' do
    UploadFile.stubs(:find).returns(nil)

    post retry_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match @file_id, flash[:alert]
    assert_match 'not found', flash[:alert]
  end

  test 'retry should redirect with alert if file status is not retryable' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.upload_bundle_id = @upload_bundle_id
      file.filename = 'retry.txt'
      file.status = FileStatus::SUCCESS
    end

    UploadFile.stubs(:find).returns(file)

    post retry_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'cannot be moved back to the pending queue', flash[:alert]
  end

  test 'retry should update file status to pending and redirect with success message for retryable status' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.upload_bundle_id = @upload_bundle_id
      file.filename = 'retry.txt'
      file.status = FileStatus::ERROR
    end
    file.expects(:update).with(status: FileStatus::PENDING).returns(true)

    UploadFile.stubs(:find).returns(file)

    UploadFilesController.any_instance.expects(:log_upload_file_event).with(
      file,
      message: 'events.upload_file.retry_request',
      metadata: { previous_status: FileStatus::ERROR }
    )

    post retry_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_includes flash[:notice], 'File has been moved back to the pending queue and will be uploaded again'
  end

  test 'retry should redirect with error message when update fails' do
    file = UploadFile.new.tap do |file|
      file.id = @file_id
      file.project_id = @project_id
      file.upload_bundle_id = @upload_bundle_id
      file.filename = 'retry_fail.txt'
      file.status = FileStatus::ERROR
    end
    file.expects(:update).with(status: FileStatus::PENDING).returns(false)

    UploadFile.stubs(:find).returns(file)

    UploadFilesController.any_instance.expects(:log_upload_file_event).never

    post retry_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)
    assert_redirected_to root_path
    follow_redirect!
    assert_includes flash[:alert], 'Could not move file back to the pending queue'
  end
end
