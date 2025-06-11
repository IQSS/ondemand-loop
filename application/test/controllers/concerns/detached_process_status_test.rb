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
    assert_equal 0, download.progress

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal false, upload.idle?
    assert_equal 5, upload.pending
    assert_equal 0, upload.progress
  end

  test 'status is active when pending = 0 and progress > 0' do
    response = Command::Response.ok(body: { pending: 0, progress: 3 })

    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal false, download.idle?
    assert_equal 0, download.pending
    assert_equal 3, download.progress

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal false, upload.idle?
    assert_equal 0, upload.pending
    assert_equal 3, upload.progress
  end

  test 'status is active when both pending > 0 and progress > 0' do
    response = Command::Response.ok(body: { pending: 2, progress: 4 })

    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal false, download.idle?
    assert_equal 2, download.pending
    assert_equal 4, download.progress

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal false, upload.idle?
    assert_equal 2, upload.pending
    assert_equal 4, upload.progress
  end

  test 'status is idle when both pending = 0 and progress = 0' do
    response = Command::Response.ok(body: { pending: 0, progress: 0 })

    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal true, download.idle?
    assert_equal 0, download.pending
    assert_equal 0, download.progress

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal true, upload.idle?
    assert_equal 0, upload.pending
    assert_equal 0, upload.progress
  end

  test 'status is idle when response status is not 200' do
    response = Command::Response.error(status: 500, message: 'server error')

    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)
    download = @instance.download_status
    assert_equal true, download.idle?
    assert_equal 'server error', download.message

    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)
    upload = @instance.upload_status
    assert_equal true, upload.idle?
    assert_equal 'server error', upload.message
  end
end
