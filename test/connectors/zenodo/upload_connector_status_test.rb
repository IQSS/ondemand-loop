require 'test_helper'

class Zenodo::UploadConnectorStatusTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @file = create_upload_file(@project, @bundle)
    @file.status = FileStatus::UPLOADING
    @status = Zenodo::UploadConnectorStatus.new(@file)
  end

  test 'progress from command client' do
    mock_client = mock('client')
    mock_client.expects(:request).returns(OpenStruct.new(body: OpenStruct.new(status: {total: 10, uploaded: 5})))
    Command::CommandClient.expects(:new).returns(mock_client)
    assert_equal 50, @status.upload_progress
  end

  test 'returns 100 for completed file' do
    @file.status = FileStatus::SUCCESS
    assert_equal 100, @status.upload_progress
  end
end
