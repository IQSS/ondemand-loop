# frozen_string_literal: true
require 'test_helper'

class ScriptLauncherTest < ActiveSupport::TestCase
  setup do
    @download_files_provider = mock('DownloadFilesProvider')
    @upload_files_provider = mock('UploadFilesProvider')
    @launcher = ScriptLauncher.new(@download_files_provider, @upload_files_provider)
  end

  test 'launch_script starts process if there are pending download files' do
    @download_files_provider.stubs(:pending_files).returns(['file1'])
    @upload_files_provider.stubs(:pending_files).returns([])

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', 'launch_detached_process.log')
    @launcher.launch_script
  end

  test 'launch_script starts process if there are pending upload files' do
    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns(['file1'])

    @launcher.expects(:start_process_from_script).with('scripts/launch_detached_process.rb', 'launch_detached_process.log')
    @launcher.launch_script
  end

  test 'launch_script logs info and does not start process if no pending files' do
    @download_files_provider.stubs(:pending_files).returns([])
    @upload_files_provider.stubs(:pending_files).returns([])

    @launcher.expects(:start_process_from_script).never
    @launcher.expects(:log_info).with('No pending files - skipping')
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
end
