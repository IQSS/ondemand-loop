# frozen_string_literal: true
require 'test_helper'

class ResetServiceTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @projects_dir = File.join(@tmp_dir, 'projects')
    @repos_dir = File.join(@tmp_dir, 'repos')
    @user_settings = File.join(@tmp_dir, 'user_settings.yml')
    @lock_file = File.join(@tmp_dir, 'detached.process.lock')
    @socket_file = File.join(@tmp_dir, 'command.server.sock')

    # Create test directories and files
    FileUtils.mkdir_p(@projects_dir)
    FileUtils.mkdir_p(@repos_dir)
    File.write(@user_settings, 'test: data')
    File.write(@lock_file, 'lock')
    File.write(@socket_file, 'socket')

    Configuration.stubs(:metadata_root).returns(@tmp_dir)
    Configuration.stubs(:detached_process_lock_file).returns(@lock_file)
    Configuration.stubs(:command_server_socket_file).returns(@socket_file)
    Project.stubs(:metadata_directory).returns(@projects_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir) if Dir.exist?(@tmp_dir)
  end

  # reset_request_allowed? tests
  test 'reset_request_allowed? returns false for GET request' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'GET'

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns false for PUT request' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'PUT'

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns false for DELETE request' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'DELETE'

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns true for POST request' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    assert ResetService.new.reset_request_allowed?(request)
  end

  # reset method tests
  test 'reset successfully shuts down process and deletes all metadata' do
    # Mock successful shutdown - lock file is removed to simulate shutdown
    mock_client = mock('CommandClient')
    mock_response = OpenStruct.new(status: 200, body: { message: 'shutdown completed' })
    mock_client.expects(:request).with { |req|
      FileUtils.rm_f(@lock_file) # Simulate lock file removal on shutdown
      true
    }.returns(mock_response)
    Command::CommandClient.stubs(:new).returns(mock_client)

    assert Dir.exist?(@projects_dir)
    assert Dir.exist?(@repos_dir)
    assert File.exist?(@user_settings)
    assert File.exist?(@lock_file)
    assert File.exist?(@socket_file)

    ResetService.new.reset

    refute Dir.exist?(@projects_dir)
    refute Dir.exist?(@repos_dir)
    refute File.exist?(@user_settings)
    refute File.exist?(@lock_file)
    refute File.exist?(@socket_file)
  end

  test 'reset handles missing socket file gracefully' do
    FileUtils.rm_f(@socket_file)

    assert_nothing_raised do
      ResetService.new.reset
    end

    # Metadata should still be deleted
    refute Dir.exist?(@projects_dir)
    refute Dir.exist?(@repos_dir)
    refute File.exist?(@user_settings)
  end

  test 'reset continues if shutdown command times out' do
    mock_client = mock('CommandClient')
    mock_client.expects(:request).raises(Command::CommandClient::TimeoutError.new('timeout'))
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Should not raise, should continue with cleanup
    assert_nothing_raised do
      ResetService.new.reset
    end

    # Process files and metadata should still be cleaned up
    refute File.exist?(@socket_file)
    refute File.exist?(@lock_file)
    refute Dir.exist?(@projects_dir)
  end

  test 'reset continues if shutdown command fails' do
    mock_client = mock('CommandClient')
    mock_client.expects(:request).raises(Command::CommandClient::CommandError.new('error'))
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Should not raise, should continue with cleanup
    assert_nothing_raised do
      ResetService.new.reset
    end

    # Process files and metadata should still be cleaned up
    refute File.exist?(@socket_file)
    refute File.exist?(@lock_file)
    refute Dir.exist?(@projects_dir)
  end

  test 'reset waits for lock file to be removed after shutdown' do
    mock_client = mock('CommandClient')
    mock_response = OpenStruct.new(status: 200, body: { message: 'shutdown completed' })
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Simulate delayed lock file removal (shutdown takes time)
    mock_client.expects(:request).with { |req|
      Thread.new do
        sleep 1.5 # Simulate shutdown delay (1.5 seconds to account for 1s interval)
        FileUtils.rm_f(@lock_file)
      end
      true
    }.returns(mock_response)

    start_time = Time.now
    ResetService.new.reset
    elapsed = Time.now - start_time

    # Should have waited for lock file removal (at least 1 check interval)
    assert elapsed >= 1.0, "Expected to wait at least 1.0s, waited #{elapsed}s"
    refute File.exist?(@lock_file)
  end

  test 'reset times out waiting for shutdown and forces cleanup' do
    mock_client = mock('CommandClient')
    mock_response = OpenStruct.new(status: 200, body: { message: 'shutdown completed' })
    mock_client.expects(:request).returns(mock_response)
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Stub wait_for_shutdown to return immediately (simulating timeout)
    ResetService.any_instance.stubs(:wait_for_shutdown).with(@lock_file).returns(nil)

    # Don't remove lock file (simulate hung process)
    ResetService.new.reset

    # Should have force-cleaned up anyway
    refute File.exist?(@socket_file)
    refute File.exist?(@lock_file)
    refute Dir.exist?(@projects_dir)
  end

  test 'reset handles missing metadata directories gracefully' do
    # Remove directories before reset
    FileUtils.rm_rf(@projects_dir)
    FileUtils.rm_rf(@repos_dir)

    # Mock shutdown
    mock_client = mock('CommandClient')
    mock_response = OpenStruct.new(status: 200, body: { message: 'shutdown completed' })
    mock_client.expects(:request).with { |req|
      FileUtils.rm_f(@lock_file) # Simulate lock file removal
      true
    }.returns(mock_response)
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Should not raise error for missing directories
    assert_nothing_raised do
      ResetService.new.reset
    end
  end

  test 'reset raises error and logs when file deletion fails' do
    reset_service = ResetService.new
    reset_service.extend(LoggingCommonMock)

    # Mock successful shutdown
    mock_client = mock('CommandClient')
    mock_response = OpenStruct.new(status: 200, body: { message: 'shutdown completed' })
    mock_client.expects(:request).with { |req|
      FileUtils.rm_f(@lock_file) # Simulate lock file removal
      true
    }.returns(mock_response)
    Command::CommandClient.stubs(:new).returns(mock_client)

    # Make file deletion fail
    FileUtils.stubs(:rm_rf).raises(StandardError, 'Permission denied')

    assert_raises(StandardError) { reset_service.reset }

    FileUtils.unstub(:rm_rf) # Unstub for teardown

    # Should have logged the error
    assert_equal 1, reset_service.logged_messages.size
    assert_match 'Failed to reset application state', reset_service.logged_messages.first[:message]
  end
end
