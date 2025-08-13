require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::UploadConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper
  include ZenodoHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @file = create_upload_file(@project, @bundle)
    @file.stubs(:file_location).returns('/tmp/file.txt')
    @file.stubs(:filename).returns('file.txt')
    @processor = Zenodo::UploadConnectorProcessor.new(@file)
  end

  test 'upload returns success when upload completes' do
    @bundle.metadata = { bucket_url: 'https://bucket', api_key: OpenStruct.new(value: 'KEY') }
    @processor = Zenodo::UploadConnectorProcessor.new(@file)

    file_name = 'file.txt'
    upload_url = FluentUrl.new('https://bucket').add_path(file_name).to_s

    uploader = mock
    uploader.expects(:upload).yields({ total: 1, uploaded: 1 })
    Zenodo::ZenodoBucketHttpUploader.expects(:new).with(
      upload_url,
      '/tmp/file.txt',
      { Zenodo::ApiService::AUTH_HEADER => 'Bearer KEY' },
    ).returns(uploader)

    result = @processor.upload
    assert_equal FileStatus::SUCCESS, result.status
  end

  test 'upload returns error when bucket_url missing' do
    @bundle.metadata = { bucket_url: nil, api_key: OpenStruct.new(value: 'KEY') }
    result = @processor.upload
    assert_equal FileStatus::ERROR, result.status
    assert_match 'Missing bucket URL', result.message
  end

  test 'process handles cancel and status' do
    @bundle.metadata = { bucket_url: 'https://bucket', api_key: OpenStruct.new(value: 'KEY') }
    @processor = Zenodo::UploadConnectorProcessor.new(@file)

    Zenodo::ZenodoBucketHttpUploader.any_instance.stubs(:upload).yields({ total: 1, uploaded: 1 })

    @processor.upload
    request = Command::Request.new(command: 'upload.status', body: { file_id: @file.id })
    status = @processor.process(request)
    assert_equal({ message: 'upload in progress', status: { total: 1, uploaded: 1 } }, status)

    cancel_req = Command::Request.new(command: 'upload.cancel', body: { file_id: @file.id })
    cancel_result = @processor.process(cancel_req)
    assert_equal true, @processor.cancelled
    assert_equal 'cancellation requested', cancel_result[:message]
  end
end
