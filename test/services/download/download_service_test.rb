# frozen_string_literal: true
require 'test_helper'
require 'ostruct'

class Download::DownloadServiceTest < ActiveSupport::TestCase

  def setup
    ConnectorClassDispatcher.stubs(:download_processor).returns(ConnectorDownloadProcessorMock.new)
  end

  test 'Only one download service should run at any given time' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      # THIS CONNECTOR WILL BLOCK ON CALLING download
      connector = ConnectorDownloadProcessorMock.new
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)
      connector_metadata = mock('connector_metadata')
      connector_metadata.stubs(:external_url).returns('http://example.com/file')

      file = mock("download_file")
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.stubs(:connector_metadata).returns(connector_metadata)
      file.stubs(:save).returns(nil)
      file.stubs(:update).returns(nil)
      file.stubs(:is_a?).with(DownloadFile).returns(true)
      file.stubs(:status).returns('', FileStatus::DOWNLOADING)

      files_provider = DownloadFilesProviderMock.new([file])

      main = download_service_thread(files_provider)
      sleep(0.1) # Allow t1 time to start and block
      # SHOULD CREATE LOCK FILE
      File.exist?(File.join(dir, 'download.lock'))

      # START OTHER
      other = download_service_thread(files_provider)

      # OTHER SHOULD FINISH IMMEDIATELY
      other.join
      refute other.alive?

      assert main.alive?, "Main DownloadService should still be blocked"
      # ONLY ONE FILE TO PROCESS => MAIN SHOULD TERMINATE AFTER COMPLETING THE PROCESSING
      connector.unblock
      main.join

      # ALL GOOD
      assert true
    end
  end

  test 'Should update the file status to downloading and success when success' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock("connector")
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::SUCCESS}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock("download_file")
      connector_metadata = mock('connector_metadata')
      connector_metadata.stubs(:external_url).returns('http://example.com/file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.stubs(:connector_metadata).returns(connector_metadata)
      file.stubs(:status).returns('', FileStatus::DOWNLOADING)
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::SUCCESS).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.started', metadata: {repo_url: 'http://example.com/file'}).once
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.finished').once

      target.start
      assert true
    end
  end

  test 'Should update the file status to downloading and error when error' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.raises(StandardError, 'An error occurred')
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      connector_metadata = mock('connector_metadata')
      connector_metadata.stubs(:external_url).returns('http://example.com/error-file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.stubs(:connector_metadata).returns(connector_metadata)
      file.stubs(:status).returns('')
      file.expects(:status).once
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::ERROR).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.started', metadata: {repo_url: 'http://example.com/error-file'}).once
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.error', metadata: {error: 'An error occurred', previous_status: ''}).once
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.finished').once
      target.start
      assert true
    end
  end

  test 'logs cancelled event when download processor returns cancelled status' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::CANCELLED}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      connector_metadata = mock('connector_metadata')
      connector_metadata.stubs(:external_url).returns('http://example.com/cancelled-file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.stubs(:connector_metadata).returns(connector_metadata)
      file.stubs(:status).returns('', FileStatus::DOWNLOADING)
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::CANCELLED).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.started', metadata: {repo_url: 'http://example.com/cancelled-file'}).once
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.finished').once

      target.start
      assert true
    end
  end

  test 'logs event when download processor returns error status' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock('connector')
      connector.expects(:download).once.returns(OpenStruct.new({status: FileStatus::ERROR, message: 'failed', error: 'An error occurred'}))
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      now_time = file_now
      file = mock('download_file')
      connector_metadata = mock('connector_metadata')
      connector_metadata.stubs(:external_url).returns('http://example.com/error-status-file')
      file.stubs(:project_id).returns('p1')
      file.stubs(:id).returns('f1')
      file.stubs(:filename).returns('file.txt')
      file.stubs(:connector_metadata).returns(connector_metadata)
      file.stubs(:status).returns(FileStatus::DOWNLOADING)
      file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::DOWNLOADING).once
      file.expects(:update).with(end_date: now_time, status: FileStatus::ERROR).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.stubs(:now).returns(now_time)
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.started', metadata: {repo_url: 'http://example.com/error-status-file'}).once
      target.expects(:log_download_file_event).with(file, message: 'events.download_file.finished').once
      target.start
      assert true
    end
  end


  private

  def download_service_thread(files_provider)
    Thread.new do
      target = Download::DownloadService.new(files_provider)
      target.stubs(:log_download_file_event)
      target.start
    end
  end

  class ConnectorDownloadProcessorMock
    def initialize
      @queue = Queue.new # Used to control when the download unblocks
    end

    def download
      @queue.pop # Blocks until something is pushed into the queue
      OpenStruct.new({status: FileStatus::SUCCESS, message: 'OK'})
    end

    def unblock
      @queue.push(nil) # Unblocks any thread waiting on download
    end
  end
end
