require 'test_helper'

class UploadStatusTest < ActiveSupport::TestCase
  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @file = create_upload_file(@project, @bundle)
    @file.status = FileStatus::UPLOADING
    @status = UploadStatus.new(@file)
  end

  test 'progress from command client' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(body: OpenStruct.new(status: {total: 10, uploaded: 5})))
    Command::CommandClient.expects(:new).returns(mock_client)
    assert_equal 50, @status.upload_progress
  end

  test 'pending file returns 0' do
    @file.status = FileStatus::PENDING
    assert_equal 0, @status.upload_progress
  end

  test 'completed file returns 100' do
    @file.status = FileStatus::SUCCESS
    assert_equal 100, @status.upload_progress
  end

  test 'error file returns 100' do
    @file.status = FileStatus::ERROR
    assert_equal 100, @status.upload_progress
  end

  test 'cancelled file returns 100' do
    @file.status = FileStatus::CANCELLED
    assert_equal 100, @status.upload_progress
  end

  test 'returns 0 when command client response has error' do
    mock_client = mock('client')
    mock_response = mock('response')
    mock_response.stubs(:error?).returns(true)
    mock_client.expects(:request).returns(mock_response)
    Command::CommandClient.expects(:new).returns(mock_client)
    @file.status = FileStatus::UPLOADING
    assert_equal 0, @status.upload_progress
  end

  test 'returns 0 when command client response body status is nil' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(error?: false, body: OpenStruct.new(status: nil)))
    Command::CommandClient.expects(:new).returns(mock_client)
    @file.status = FileStatus::UPLOADING
    assert_equal 0, @status.upload_progress
  end

  test 'calculates progress correctly from command response' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(error?: false, body: OpenStruct.new(status: {total: 200, uploaded: 75})))
    Command::CommandClient.expects(:new).returns(mock_client)
    @file.status = FileStatus::UPLOADING
    assert_equal 37, @status.upload_progress
  end

  test 'caps progress at 100 percent' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(error?: false, body: OpenStruct.new(status: {total: 100, uploaded: 150})))
    Command::CommandClient.expects(:new).returns(mock_client)
    @file.status = FileStatus::UPLOADING
    assert_equal 100, @status.upload_progress
  end

  test 'handles zero total gracefully' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(error?: false, body: OpenStruct.new(status: {total: 0, uploaded: 0})))
    Command::CommandClient.expects(:new).returns(mock_client)
    @file.status = FileStatus::UPLOADING
    assert_equal 0, @status.upload_progress
  end
end
