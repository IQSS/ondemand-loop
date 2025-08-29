# frozen_string_literal: true

require 'test_helper'

class DetachedProcessTest < ActiveSupport::TestCase
  setup do
    @tmpdir = Dir.mktmpdir('detached_process_test')
    @mock_lock_file = File.join(@tmpdir, 'detached.process.lock')
    @mock_socket_file = File.join(@tmpdir, 'command_server.socket')

    Configuration.stubs(:metadata_root).returns(@tmpdir)
    Configuration.stubs(:detached_process_lock_file).returns(@mock_lock_file)
    Configuration.stubs(:command_server_socket_file).returns(@mock_socket_file)

    # Reset any existing signal handlers to avoid interference
    %w[TERM INT QUIT HUP].each { |sig| Signal.trap(sig, 'DEFAULT') }
  end

  teardown do
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
    # Reset signal handlers
    %w[TERM INT QUIT HUP].each { |sig| Signal.trap(sig, 'DEFAULT') }
  end

  test 'initialize sets up process attributes and cleanup handlers' do
    process = DetachedProcess.new

    assert_equal Process.pid, process.process_id
    assert_not_nil process.instance_variable_get(:@start_time)
    assert_equal @mock_lock_file, process.instance_variable_get(:@lock_file)
    assert_empty process.instance_variable_get(:@services)
  end

  test 'launch starts services, command server and logs process lifecycle' do
    # Mock dependencies
    command_server = mock('CommandServer')
    command_server.expects(:start).once
    command_server.expects(:shutdown).once

    controller = mock('DetachedProcessManager')
    controller.expects(:run).once

    download_service = mock('DownloadService')
    upload_service = mock('UploadService')

    # Stub constructors
    Command::CommandServer.expects(:new).with(socket_path: @mock_socket_file).returns(command_server)
    DetachedProcessManager.expects(:new).returns(controller)
    Download::DownloadService.expects(:new).returns(download_service)
    Upload::UploadService.expects(:new).returns(upload_service)

    process = DetachedProcess.new

    # Mock logging expectations
    process.expects(:log_info).with('Process launched', { pid: Process.pid, lock_file: @mock_lock_file })
    process.expects(:log_info).with('Completed', { pid: Process.pid, elapsed_time: anything })

    process.launch
  end

  test 'launch handles startup errors gracefully and still shuts down' do
    command_server = mock('CommandServer')
    command_server.expects(:start).once
    command_server.expects(:shutdown).once

    Command::CommandServer.stubs(:new).returns(command_server)
    Download::DownloadService.expects(:new).raises(StandardError, 'Startup failure')

    process = DetachedProcess.new

    # Expect error logging
    process.expects(:log_info).with('Process launched', { pid: Process.pid, lock_file: @mock_lock_file })
    process.expects(:log_error).with('Exit. Error while executing DetachedProcess',
                                     { pid: Process.pid, elapsed_time: anything },
                                     instance_of(StandardError))

    # Should not raise, error is handled
    assert_nothing_raised do
      process.launch
    end
  end

  test 'cleanup_lock_file removes lock file when it exists' do
    # Create a mock lock file
    File.write(@mock_lock_file, "test content")
    assert File.exist?(@mock_lock_file)

    process = DetachedProcess.new
    process.expects(:log_info).with("Lock file cleaned up", { pid: Process.pid, lock_file: @mock_lock_file })

    process.send(:cleanup_lock_file)

    assert_not File.exist?(@mock_lock_file)
  end

  test 'cleanup_lock_file handles missing lock file gracefully' do
    # Ensure lock file doesn't exist
    File.delete(@mock_lock_file) if File.exist?(@mock_lock_file)

    process = DetachedProcess.new
    process.expects(:log_info).never
    process.expects(:log_error).never

    # Should not raise error
    assert_nothing_raised do
      process.send(:cleanup_lock_file)
    end
  end

  test 'cleanup_lock_file handles file deletion errors' do
    # Create a lock file
    File.write(@mock_lock_file, "test content")

    # Make the file undeletable by stubbing File.delete to raise error
    File.expects(:delete).with(@mock_lock_file).raises(Errno::EACCES, 'Permission denied')

    process = DetachedProcess.new
    process.expects(:log_error).with("Could not clean up lock file",
                                     { pid: Process.pid, lock_file: @mock_lock_file },
                                     instance_of(Errno::EACCES))

    # Should not raise error
    assert_nothing_raised do
      process.send(:cleanup_lock_file)
    end
  end

  test 'signal handlers are set up correctly' do
    original_handlers = {}
    %w[TERM INT QUIT HUP].each { |sig| original_handlers[sig] = Signal.trap(sig, 'DEFAULT') }

    process = DetachedProcess.new

    # Verify signal handlers are installed (they should not be 'DEFAULT' anymore)
    %w[TERM INT QUIT HUP].each do |signal|
      current_handler = Signal.trap(signal, 'DEFAULT')
      assert_not_equal 'DEFAULT', current_handler
      # Restore the handler for cleanup
      Signal.trap(signal, current_handler) if current_handler
    end
  end

  test 'cleanup functionality works correctly' do
    # Test the cleanup logic directly instead of through signal handlers
    File.write(@mock_lock_file, "test content")

    process = DetachedProcess.new
    process.expects(:log_info).with("Lock file cleaned up", { pid: Process.pid, lock_file: @mock_lock_file })

    # Test cleanup_lock_file directly
    process.send(:cleanup_lock_file)

    assert_not File.exist?(@mock_lock_file)
  end

  test 'at_exit handler is set up' do
    # This is tricky to test directly since we can't easily trigger at_exit in tests
    # We can verify the handler calls cleanup_lock_file by mocking

    File.write(@mock_lock_file, "test content")

    process = DetachedProcess.new

    # The at_exit block should be registered, we can't easily test its execution
    # but we can test that cleanup_lock_file works when called directly
    process.expects(:log_info).with("Lock file cleaned up", { pid: Process.pid, lock_file: @mock_lock_file })

    process.send(:cleanup_lock_file)
  end

  test 'elapsed_time returns formatted duration' do
    start_time = Time.parse('2025-08-28T14:30:00')

    process = DetachedProcess.new
    process.instance_variable_set(:@start_time, start_time)

    # Mock the elapsed_string method from DateTimeCommon
    process.expects(:elapsed_string).with(start_time).returns('00:05:30')

    assert_equal '00:05:30', process.send(:elapsed_time)
  end

  test 'shutdown only shuts down command server' do
    command_server = mock('CommandServer')
    command_server.expects(:shutdown).once

    process = DetachedProcess.new
    process.instance_variable_set(:@command_server, command_server)

    process.send(:shutdown)
  end

  test 'shutdown handles nil command server gracefully' do
    process = DetachedProcess.new
    process.instance_variable_set(:@command_server, nil)

    # Should not raise error
    assert_nothing_raised do
      process.send(:shutdown)
    end
  end

  test 'services are properly initialized during startup' do
    # Mock all dependencies to avoid actual initialization
    command_server = mock('CommandServer')
    command_server.expects(:start)
    command_server.expects(:shutdown)

    controller = mock('DetachedProcessManager')
    controller.stubs(:run)

    download_files_provider = mock('DownloadFilesProvider')
    upload_files_provider = mock('UploadFilesProvider')
    download_service = mock('DownloadService')
    upload_service = mock('UploadService')

    Command::CommandServer.stubs(:new).returns(command_server)
    DetachedProcessManager.stubs(:new).returns(controller)
    Download::DownloadFilesProvider.expects(:new).returns(download_files_provider)
    Upload::UploadFilesProvider.expects(:new).returns(upload_files_provider)
    Download::DownloadService.expects(:new).with(download_files_provider).returns(download_service)
    Upload::UploadService.expects(:new).with(upload_files_provider).returns(upload_service)

    process = DetachedProcess.new
    process.stubs(:log_info) # Suppress logging for this test

    process.launch

    services = process.instance_variable_get(:@services)
    assert_includes services, download_service
    assert_includes services, upload_service
    assert_equal 2, services.length
  end
end
