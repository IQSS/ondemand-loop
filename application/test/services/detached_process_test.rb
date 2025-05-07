# frozen_string_literal: true

require 'test_helper'

class DetachedProcessTest < ActiveSupport::TestCase
  setup do
    @tmpdir = Dir.mktmpdir
    @mock_lock_file = File.join(@tmpdir, 'detached.process.lock').to_s
    Configuration.stubs(:metadata_root).returns(@tmpdir.to_s)
    Configuration.stubs(:download_server_socket_file).returns(File.join(@tmpdir, 'mock.socket').to_s)
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
  end

  test 'launch starts controller and logs process lifecycle' do
    # Stub services and controller
    command_server = mock('CommandServer')
    command_server.expects(:shutdown).once

    controller = mock('DetachedProcessController')
    controller.expects(:run).once

    DetachedProcessController.stubs(:new).returns(controller)
    Download::Command::DownloadCommandServer.stubs(:new).returns(command_server)
    Download::DownloadService.stubs(:new)
    Upload::UploadService.stubs(:new)

    process = DetachedProcess.new

    File.delete(@mock_lock_file) if File.exist?(@mock_lock_file)

    process.launch

    assert_equal Process.pid, process.process_id
  end

  test 'launch exits early if lock is already held' do
    File.open(@mock_lock_file, 'w') do |f|
      f.flock(File::LOCK_EX | File::LOCK_NB) # Simulate existing lock

      process = DetachedProcess.new

      # Expect nothing else to be initialized
      Download::Command::DownloadCommandServer.expects(:new).never
      DetachedProcessController.expects(:new).never

      process.launch
    end
  end

  test 'launch still shuts down command server if error raised during startup' do
    command_server = mock('CommandServer')
    command_server.expects(:shutdown).once

    Download::Command::DownloadCommandServer.stubs(:new).returns(command_server)

    Download::DownloadService.stubs(:new).raises(StandardError, 'Startup failure')
    Upload::UploadService.stubs(:new)

    process = DetachedProcess.new

    File.delete(@mock_lock_file) if File.exist?(@mock_lock_file)

    assert_nothing_raised do
      process.launch
    end
  end
end
