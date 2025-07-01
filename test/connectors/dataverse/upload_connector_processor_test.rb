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
    Upload::MultipartHttpRubyUploader.any_instance.stubs(:upload).yields({total:1, uploaded:1})
    result = @processor.upload
    assert_equal FileStatus::SUCCESS, result.status
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
