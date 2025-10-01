# frozen_string_literal: true
require 'test_helper'

class ResetServiceTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @lock_file = File.join(@tmp_dir, 'lock_file')
    @socket_file = File.join(@tmp_dir, 'command.server.sock')

    File.write(@lock_file, 'lock')
    File.write(@socket_file, 'socket')

    Configuration.stubs(:metadata_root).returns(@tmp_dir)
    Configuration.stubs(:detached_process_lock_file).returns(@lock_file)
    Configuration.stubs(:command_server_socket_file).returns(@socket_file)

    FileUtils.mkdir_p(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir) if Dir.exist?(@tmp_dir)
  end

  test 'reset deletes metadata directory and files' do
    test_file = File.join(@tmp_dir, 'some_file')
    File.write(test_file, 'data')

    assert Dir.exist?(@tmp_dir)
    assert File.exist?(@lock_file)
    assert File.exist?(@socket_file)

    ResetService.new.reset

    refute Dir.exist?(@tmp_dir)
    refute File.exist?(@lock_file)
    refute File.exist?(@socket_file)
  end

  test 'logs error when deletion fails' do
    reset_service = ResetService.new
    reset_service.extend(LoggingCommonMock)

    FileUtils.stubs(:rm_rf).raises(StandardError, 'boom')

    assert_raises(StandardError) { reset_service.reset }
    FileUtils.unstub(:rm_rf)

    assert Dir.exist?(@tmp_dir)
    assert_equal 1, reset_service.logged_messages.size
    assert_match 'Failed to reset application state', reset_service.logged_messages.first[:message]
  end

  # Tests for reset_request_allowed?
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

  test 'reset_request_allowed? returns false when active download files exist' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    project = download_project(files: 1)
    project.download_files.first.status = FileStatus::DOWNLOADING
    Project.stubs(:all).returns([project])

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns false when pending download files exist' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    project = download_project(files: 1)
    project.download_files.first.status = FileStatus::PENDING
    Project.stubs(:all).returns([project])

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns false when active upload files exist' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    project = upload_project(files: 1)
    project.upload_bundles.first.files.first.status = FileStatus::UPLOADING
    Project.stubs(:all).returns([project])

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns false when pending upload files exist' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    project = upload_project(files: 1)
    project.upload_bundles.first.files.first.status = FileStatus::PENDING
    Project.stubs(:all).returns([project])

    refute ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns true when POST request and no active files' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    # Create projects with completed files only
    download_proj = download_project(files: 1)
    download_proj.download_files.first.status = FileStatus::SUCCESS

    upload_proj = upload_project(files: 1)
    upload_proj.upload_bundles.first.files.first.status = FileStatus::SUCCESS

    Project.stubs(:all).returns([download_proj, upload_proj])

    assert ResetService.new.reset_request_allowed?(request)
  end

  test 'reset_request_allowed? returns true when POST request and no files exist' do
    request = ActionDispatch::TestRequest.create
    request.request_method = 'POST'

    Project.stubs(:all).returns([])

    assert ResetService.new.reset_request_allowed?(request)
  end
end
