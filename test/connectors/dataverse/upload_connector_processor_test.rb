require 'test_helper'

class Dataverse::UploadConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', dataset_id: 'DS1', api_key: OpenStruct.new(value: 'KEY'))
    @bundle.stubs(:connector_metadata).returns(meta)
    @file = create_upload_file(@project, @bundle)
    @file.stubs(:file_location).returns('/tmp/file.txt')
    @file.stubs(:filename).returns('file.txt')
    @processor = Dataverse::UploadConnectorProcessor.new(@file)
  end

  test 'upload delegates to uploader and returns success' do
    json = load_file_fixture(File.join('dataverse', 'upload_file_response', 'valid_response.json'))
    Upload::MultipartHttpRubyUploader.any_instance.stubs(:upload).yields({total:1, uploaded:1}).returns(json)
    Digest::MD5.expects(:file).with('/tmp/file.txt').returns(stub(hexdigest: '5f02321dba2a37355a9f1f810565c1c8'))

    result = @processor.upload
    assert_equal FileStatus::SUCCESS, result.status
  end

  test 'upload returns error when md5 mismatch' do
    json = load_file_fixture(File.join('dataverse', 'upload_file_response', 'valid_response.json'))
    Upload::MultipartHttpRubyUploader.any_instance.stubs(:upload).yields({total:1, uploaded:1}).returns(json)
    Digest::MD5.expects(:file).with('/tmp/file.txt').returns(stub(hexdigest: 'deadbeef'))

    result = @processor.upload
    assert_equal FileStatus::ERROR, result.status
    assert_match 'md5 check failed', result.message
  end

  test 'process cancel sets flag' do
    req = OpenStruct.new(command: 'upload.cancel', body: OpenStruct.new(file_id: @file.id))
    res = @processor.process(req)
    assert_equal 'cancellation requested', res[:message]
    assert @processor.cancelled
  end

  test 'process status returns progress' do
    ctx = {total:1, uploaded:0}
    @processor.instance_variable_set(:@status_context, ctx)
    req = OpenStruct.new(command: 'upload.status', body: OpenStruct.new(file_id: @file.id))
    res = @processor.process(req)
    assert_equal ctx, res[:status]
  end
end
