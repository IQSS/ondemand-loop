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

  test 'download_status returns idle if response is 200 and no progress or pending' do
    response = Command::Response.ok(body: { pending: 0, progress: 0 })
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)

    result = @instance.download_status
    assert result.idle?
    assert_equal 0, result.pending
    assert_equal 0, result.progress
  end

  test 'upload_status returns active if response has progress' do
    response = Command::Response.ok(body: { pending: 0, progress: 3 })
    @mock_client.stubs(:request).with { |req| req.command == 'detached.upload.status' }.returns(response)

    result = @instance.upload_status
    refute result.idle?
    assert_equal 3, result.progress
  end

  test 'download_status returns idle if status is not 200' do
    response = Command::Response.error(status: 500, message: 'failure')
    @mock_client.stubs(:request).with { |req| req.command == 'detached.download.status' }.returns(response)

    result = @instance.download_status
    assert result.idle?
    assert_equal 'failure', result.message
  end

  test 'from_download_files_summary sets idle? true if no downloading or pending' do
    summary = OpenStruct.new(
      pending: 0,
      downloading: 0,
      success: 2,
      error: 1,
      cancelled: 1,
    )

    result = @instance.from_download_files_summary(summary)
    assert result.idle?
    assert_equal 0, result.progress
    assert_equal 4, result.completed
  end

  test 'from_download_files_summary sets idle? false if downloading or pending present' do
    summary = OpenStruct.new(
      pending: 1,
      downloading: 1,
      success: 2,
      error: 1,
      cancelled: 1,
    )

    result = @instance.from_download_files_summary(summary)
    refute result.idle?
    assert_equal 1, result.progress
    assert_equal 4, result.completed
  end

  test 'from_upload_files_summary sets idle? true if no uploading or pending' do
    summary = OpenStruct.new(
      pending: 0,
      uploading: 0,
      success: 3,
      error: 0,
      cancelled: 0,
    )

    result = @instance.from_upload_files_summary(summary)
    assert result.idle?
    assert_equal 0, result.progress
    assert_equal 3, result.completed
  end

  test 'from_upload_files_summary sets idle? false if uploading present' do
    summary = OpenStruct.new(
      pending: 2,
      uploading: 2,
      success: 1,
      error: 0,
      cancelled: 1,
    )

    result = @instance.from_upload_files_summary(summary)
    refute result.idle?
    assert_equal 2, result.progress
    assert_equal 2, result.completed
  end
end
