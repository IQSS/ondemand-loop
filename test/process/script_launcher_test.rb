# frozen_string_literal: true
require 'test_helper'

class ScriptLauncherTest < ActiveSupport::TestCase
  setup do
    @download_files_provider = mock('DownloadFilesProvider')
    @upload_files_provider = mock('UploadFilesProvider')
    @launcher = ScriptLauncher.new(@download_files_provider, @upload_files_provider)

    # Create a temporary directory and lock file path
    @temp_dir = Dir.mktmpdir('script_launcher_test')
    @lock_file_path = File.join(@temp_dir, 'detached_process.lock')
    Configuration.stubs(:detached_process_lock_file).returns(@lock_file_path)
  end

  teardown do
    # Clean up the entire temporary directory
    FileUtils.remove_entry(@temp_dir) if @temp_dir && Dir.exist?(@temp_dir)
  end

  test 'launch_script logs info and does not start process if no pending files' do
    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns([])

    @launcher.expects(:start_process_from_script).never
    @launcher.expects(:log_info).with('No pending files - skipping')
    @launcher.launch_script
  end

  test 'launch_script starts process if there are pending download files and no lock' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(12345)
    @launcher.expects(:log_info).with("Launching Detached Process Script...", { lock_file: @lock_file_path })
    @launcher.expects(:log_info).with("DetachedProcess started", {
      pid: 12345,
      lock_file: @lock_file_path,
      started_at: anything
    })
    @launcher.stubs(:now).returns('2025-08-28T14:30:45')

    @launcher.launch_script

    # Verify lock file was created with correct content
    assert File.exist?(@lock_file_path)
    content = File.read(@lock_file_path)
    lines = content.split("\n")
    assert_equal '12345', lines[0]
    assert_equal '2025-08-28T14:30:45', lines[1]
  end

  test 'launch_script starts process if there are pending upload files and no lock' do
    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns(['file1'])

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(12345)
    @launcher.expects(:log_info).with("Launching Detached Process Script...", { lock_file: @lock_file_path })
    @launcher.expects(:log_info).with("DetachedProcess started", {
      pid: 12345,
      lock_file: @lock_file_path,
      started_at: anything
    })
    @launcher.stubs(:now).returns('2025-08-28T14:30:45')

    @launcher.launch_script
  end

  test 'launch_script skips if process is already running (within 60s grace period)' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Create a lock file with recent timestamp (within 60s)
    File.write(@lock_file_path, "12345\n2025-08-28T14:30:45")
    @launcher.stubs(:to_time).with('2025-08-28T14:30:45').returns(Time.parse('2025-08-28T14:30:45'))
    @launcher.stubs(:elapsed).with(Time.parse('2025-08-28T14:30:45')).returns(30) # 30 seconds ago

    @launcher.expects(:start_process_from_script).never
    @launcher.expects(:log_info).with('Skip. DetachedProcess already running', { lock_file: @lock_file_path })

    @launcher.launch_script
  end

  test 'launch_script skips if process is running and exists after 60s' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Create a lock file with older timestamp (> 60s)
    File.write(@lock_file_path, "12345\n2025-08-28T14:30:45")
    @launcher.stubs(:to_time).with('2025-08-28T14:30:45').returns(Time.parse('2025-08-28T14:30:45'))
    @launcher.stubs(:elapsed).with(Time.parse('2025-08-28T14:30:45')).returns(120) # 2 minutes ago
    @launcher.stubs(:elapsed_string).with(Time.parse('2025-08-28T14:30:45')).returns('00:02:00')

    # Mock that process exists
    Process.expects(:getpgid).with(12345).returns(12345)

    @launcher.expects(:start_process_from_script).never
    @launcher.expects(:log_info).with('Skip. DetachedProcess already running', { lock_file: @lock_file_path })
    @launcher.expects(:log_info).with("Found running DetachedProcess", {
      pid: 12345,
      started_at: '2025-08-28T14:30:45',
      running_for: '00:02:00'
    })

    @launcher.launch_script
  end

  test 'launch_script starts new process if old process no longer exists' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Create a lock file with older timestamp (> 60s)
    File.write(@lock_file_path, "12345\n2025-08-28T14:30:45")
    @launcher.stubs(:to_time).with('2025-08-28T14:30:45').returns(Time.parse('2025-08-28T14:30:45'))
    @launcher.stubs(:elapsed).with(Time.parse('2025-08-28T14:30:45')).returns(120) # 2 minutes ago
    @launcher.stubs(:elapsed_string).with(Time.parse('2025-08-28T14:30:45')).returns('00:02:00')
    @launcher.stubs(:now).returns('2025-08-28T14:32:45')

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    # Mock that process doesn't exist
    Process.expects(:getpgid).with(12345).raises(Errno::ESRCH)

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(67890)
    @launcher.expects(:log_info).with("Stale lock file detected - process no longer exists", {
      pid: 12345,
      was_started_at: '2025-08-28T14:30:45',
      was_running_for: '00:02:00'
    })
    @launcher.expects(:log_info).with("Launching Detached Process Script...", { lock_file: @lock_file_path })
    @launcher.expects(:log_info).with("DetachedProcess started", {
      pid: 67890,
      lock_file: @lock_file_path,
      started_at: '2025-08-28T14:32:45'
    })

    @launcher.launch_script
  end

  test 'launch_script skips if another request is processing (flock fails)' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Simulate another process holding the lock
    File.open(@lock_file_path, File::CREAT | File::RDWR) do |other_lock|
      other_lock.flock(File::LOCK_EX)

      @launcher.expects(:start_process_from_script).never
      @launcher.expects(:log_info).with('Skip. Another request is processing the lock', { lock_file: @lock_file_path })

      # This should timeout quickly due to LOCK_NB
      @launcher.launch_script
    end
  end

  test 'launch_script handles empty lock file' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Create empty lock file
    File.write(@lock_file_path, '')

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(12345)
    @launcher.stubs(:now).returns('2025-08-28T14:30:45')

    @launcher.launch_script
  end

  test 'launch_script handles malformed lock file' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    # Create malformed lock file (only one line)
    File.write(@lock_file_path, '12345')

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(67890)
    @launcher.stubs(:now).returns('2025-08-28T14:30:45')

    @launcher.launch_script
  end

  test 'launch_script handles Process.getpgid errors gracefully' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    File.write(@lock_file_path, "12345\n2025-08-28T14:30:45")
    @launcher.stubs(:to_time).with('2025-08-28T14:30:45').returns(Time.parse('2025-08-28T14:30:45'))
    @launcher.stubs(:elapsed).with(Time.parse('2025-08-28T14:30:45')).returns(120)

    expected_log_filename = 'launch_detached_process-2025-W35.log'
    @launcher.expects(:script_log_filename).returns(expected_log_filename)

    # Mock unexpected error
    Process.expects(:getpgid).with(12345).raises(StandardError, 'Unexpected error')

    @launcher.expects(:log_warn).with("Error checking process status", { pid: 12345, error: 'Unexpected error' })
    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', expected_log_filename).returns(67890)
    @launcher.stubs(:now).returns('2025-08-28T14:32:45')

    @launcher.launch_script
  end

  test 'pending_files? returns true if download or upload files are pending' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])
    assert @launcher.pending_files?

    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns(['file1'])
    assert @launcher.pending_files?
  end

  test 'pending_files? returns false if no files are pending' do
    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns([])
    refute @launcher.pending_files?
  end

  test 'start_process_from_script spawns process and detaches' do
    Configuration.stubs(:ruby_binary).returns('ruby')
    Configuration.stubs(:metadata_root).returns('/tmp')
    Process.expects(:spawn).with('ruby', 'script.rb',
                                 out: ['/tmp/log.log', 'a'],
                                 err: ['/tmp/log.log', 'a'],
                                 in: '/dev/null',
                                 pgroup: true
    ).returns(123)
    Process.expects(:detach).with(123)

    result = @launcher.start_process_from_script('script.rb', 'log.log')
    assert_equal 123, result
  end

  test 'update_lock_file handles write errors' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    @launcher.stubs(:now).returns('2025-08-28T14:30:45')

    # Mock file operations to simulate write error
    mock_file = mock('file')
    mock_file.expects(:rewind)
    mock_file.expects(:write).raises(IOError, 'Disk full')

    @launcher.expects(:log_error).with("Failed to update lock file", { pid: 12345, error: 'Disk full' })

    assert_raises(IOError) do
      @launcher.send(:update_lock_file, mock_file, 12345)
    end
  end

  test 'script_log_filename generates correct weekly log filename' do
    # Stub Date.today to return a specific date
    Date.stubs(:today).returns(Date.new(2025, 8, 28)) # Thursday of week 35, 2025

    expected_filename = 'launch_detached_process-2025-W35.log'
    assert_equal expected_filename, @launcher.send(:script_log_filename)
  end
end
