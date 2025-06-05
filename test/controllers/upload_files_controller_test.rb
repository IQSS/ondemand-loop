require 'test_helper'

class UploadFilesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @project_id = 'test-project'
    @upload_bundle_id = 'test-collection'
    @file_id = 'file-123'
    @test_path = Rails.root.join('test/fixtures/files/sample.txt').to_s
  end

  test 'index should return success' do
    collection = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(collection)

    get project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id)

    assert_response :ok
  end

  test 'create should return not found if upload batch does not exist' do
    UploadBundle.stubs(:find).returns(nil)

    post project_upload_bundle_upload_files_url(@project_id, @upload_bundle_id), params: {
      path: @test_path
    }

    assert_response :not_found
  end

  test 'should return bad request if file is invalid' do
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
    UploadBundle.stubs(:find).returns(mock)

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

  test 'delete should destroy upload file and redirect' do
    file = mock
    file.stubs(:nil?).returns(false)
    file.stubs(:filename).returns('delete.txt')
    file.expects(:destroy)

    UploadFile.stubs(:find).with(@project_id, @upload_bundle_id, @file_id).returns(file)

    delete project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)

    assert_redirected_to root_path
    assert_equal 'Upload file removed from bundle. delete.txt', flash[:notice]
  end

  test 'cancel should return not found if file is missing on cancel' do
    UploadFile.stubs(:find).returns(nil)

    post cancel_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)

    assert_response :not_found
    assert_match /file not found/, @response.body
  end

  test 'cancel should cancel uploading file and return no content' do
    file = UploadFile.new
    file.stubs(:status).returns(FileStatus::UPLOADING)
    file.expects(:update).with(start_date: anything, end_date: anything, status: FileStatus::CANCELLED)

    UploadFile.stubs(:find).returns(file)

    mock_response = mock
    mock_response.stubs(:status).returns(200)

    Command::CommandClient.any_instance.stubs(:request).returns(mock_response)

    post cancel_project_upload_bundle_upload_file_url(@project_id, @upload_bundle_id, @file_id)

    assert_response :no_content
  end
end
