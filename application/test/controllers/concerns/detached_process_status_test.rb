# frozen_string_literal: true
require 'test_helper'

class DetachedProcessStatusTest < ActiveSupport::TestCase
  class DummyStatus
    include DetachedProcessStatus
  end

  def setup
    @instance = DummyStatus.new
    @mock_client = mock('CommandClient')
    Command::CommandClient.stubs(:new).returns(@mock_client)
    ::Configuration.stubs(:command_server_socket_file).returns('/tmp/socket')
  end

  test 'status is active when pending > 0 and progress = 0' do
    response = Command::Response.ok(body: { pending: 5, progress: 0 })
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal false, download.idle?
    assert_equal 5, download.pending

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal false, upload.idle?
    assert_equal 5, upload.pending
  end

  test 'status is active when pending = 0 and progress > 0' do
    response = Command::Response.ok(body: { pending: 0, progress: 2 })
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal false, download.idle?
    assert_equal 2, download.progress

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal false, upload.idle?
    assert_equal 2, upload.progress
  end

  test 'status is idle when both pending and progress are 0' do
    response = Command::Response.ok(body: { pending: 0, progress: 0 })
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal true, download.idle?

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal true, upload.idle?
  end

  test 'status is idle when response status is not 200' do
    response = Command::Response.error(status: 500, message: 'fail')
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal true, download.idle?
    assert_equal 'fail', download.message

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal true, upload.idle?
    assert_equal 'fail', upload.message
  end

  test 'from_files_summary computes correct idle and completed values' do
    summary = OpenStruct.new(
      pending: 2,
      downloading: 1,
      success: 4,
      error: 1,
      cancelled: 1,
    )

    result = @instance.from_files_summary(summary)

    assert_equal false, result.idle?
    assert_equal 1, result.progress
    assert_equal 6, result.completed
    assert_equal 2, result.pending
  end

  test 'from_files_summary marks as idle when pending and downloading are 0' do
    summary = OpenStruct.new(
      pending: 0,
      downloading: 0,
      success: 3,
      error: 0,
      cancelled: 2,
    )

    result = @instance.from_files_summary(summary)

    assert_equal true, result.idle?
    assert_equal 0, result.progress
    assert_equal 5, result.completed
  end
end
