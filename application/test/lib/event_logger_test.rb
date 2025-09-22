# frozen_string_literal: true
require 'test_helper'

class EventLoggerTest < ActiveSupport::TestCase
  include EventLogger

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    UploadFile.stubs(:metadata_root_directory).returns(@tmp_dir)

    @project = Project.new(
      id: 'project-123',
      name: 'Test Project',
      download_dir: File.join(@tmp_dir, 'downloads')
    )

    @download_file = DownloadFile.new(
      id: 'download-456',
      project_id: 'project-123',
      filename: 'test-download.txt',
      status: FileStatus::PENDING,
      type: ConnectorType::DATAVERSE,
      size: 1024,
      metadata: {}
    )

    @upload_file = UploadFile.new(
      id: 'upload-789',
      project_id: 'project-123',
      upload_bundle_id: 'bundle-123',
      file_location: '/tmp/test-upload.txt',
      filename: 'test-upload.txt',
      status: FileStatus::PENDING,
      size: 2048
    )

    # Mock ProjectEventList and Event
    @mock_event_list = mock('ProjectEventList')
    @mock_event = mock('Event')
    ProjectEventList.stubs(:new).returns(@mock_event_list)
    Event.stubs(:new).returns(@mock_event)

    # Mock LoggingCommon
    LoggingCommon.stubs(:log_info)
    LoggingCommon.stubs(:log_error)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'log_project_event should call log_event with correct parameters' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'Project',
      entity_id: 'project-123',
      message: 'Project created',
      metadata: { source: 'test' }
    ).returns(true)

    result = log_project_event(@project, message: 'Project created', metadata: { source: 'test' })
    assert result
  end

  test 'log_project_event should raise error for non-Project object' do
    assert_raises(ArgumentError, "Expected Project model, got String") do
      log_project_event('not-a-project', message: 'Test message')
    end
  end

  test 'log_download_file_event should call log_event with correct parameters' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'download_file',
      entity_id: 'download-456',
      message: 'File downloaded',
      metadata: { filename: 'test-download.txt', status: 'pending', custom: 'data' }
    ).returns(true)

    result = log_download_file_event(@download_file, message: 'File downloaded', metadata: { custom: 'data' })
    assert result
  end

  test 'log_download_file_event should raise error for non-DownloadFile object' do
    assert_raises(ArgumentError, "Expected DownloadFile model, got Project") do
      log_download_file_event(@project, message: 'Test message')
    end
  end

  test 'log_upload_file_event should call log_event with correct parameters' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'upload_file',
      entity_id: 'upload-789',
      message: 'File uploaded',
      metadata: { filename: 'test-upload.txt', status: 'pending', extra: 'info' }
    ).returns(true)

    result = log_upload_file_event(@upload_file, message: 'File uploaded', metadata: { extra: 'info' })
    assert result
  end

  test 'log_upload_file_event should raise error for non-UploadFile object' do
    assert_raises(ArgumentError, "Expected UploadFile model, got String") do
      log_upload_file_event('not-a-file', message: 'Test message')
    end
  end

  test 'log_event should save event successfully' do
    event_attributes = {
      project_id: 'project-123',
      entity_type: 'Project',
      entity_id: 'project-123',
      message: 'Test event',
      metadata: { test: 'data' }
    }

    saved_event = { id: 'event-123', **event_attributes }
    @mock_event.expects(:to_h).returns(saved_event)
    @mock_event_list.expects(:add).with(@mock_event).returns(@mock_event)
    LoggingCommon.expects(:log_info).with('Event saved', saved_event)

    result = log_event(**event_attributes)
    assert result
  end

  test 'log_event should handle failed event save' do
    event_attributes = {
      project_id: 'project-123',
      entity_type: 'Project',
      entity_id: 'project-123',
      message: 'Test event',
      metadata: { test: 'data' }
    }

    @mock_event_list.expects(:add).with(@mock_event).returns(nil)
    LoggingCommon.expects(:log_error).with('Cannot log event', { event: event_attributes })

    result = log_event(**event_attributes)
    refute result
  end

  test 'log_event should handle exceptions gracefully' do
    event_attributes = {
      project_id: 'project-123',
      entity_type: 'Project',
      entity_id: 'project-123',
      message: 'Test event',
      metadata: { test: 'data' }
    }

    exception = StandardError.new('Database error')
    @mock_event_list.expects(:add).raises(exception)
    LoggingCommon.expects(:log_error).with('Cannot log event', event_attributes, exception)

    result = log_event(**event_attributes)
    refute result
  end

  test 'log_project_event with empty metadata should use default empty hash' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'Project',
      entity_id: 'project-123',
      message: 'Project created',
      metadata: {}
    ).returns(true)

    result = log_project_event(@project, message: 'Project created')
    assert result
  end

  test 'log_download_file_event should merge metadata with file attributes' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'download_file',
      entity_id: 'download-456',
      message: 'Download started',
      metadata: { filename: 'test-download.txt', status: 'pending', user_id: '123' }
    ).returns(true)

    result = log_download_file_event(@download_file, message: 'Download started', metadata: { user_id: '123' })
    assert result
  end

  test 'log_upload_file_event should merge metadata with file attributes' do
    expects(:log_event).with(
      project_id: 'project-123',
      entity_type: 'upload_file',
      entity_id: 'upload-789',
      message: 'Upload completed',
      metadata: { filename: 'test-upload.txt', status: 'pending', session_id: 'abc123' }
    ).returns(true)

    result = log_upload_file_event(@upload_file, message: 'Upload completed', metadata: { session_id: 'abc123' })
    assert result
  end
end