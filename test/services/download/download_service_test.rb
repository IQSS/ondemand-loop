# frozen_string_literal: true
require 'test_helper'

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

      file = stub({save_status!: nil})
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
      connector.expects(:download).once
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      file = mock("download_file")
      file.expects(:save_status!).with('downloading').once
      file.expects(:save_status!).with('success').once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.start
    end
  end

  test 'Should update the file status to downloading and error when error' do
    Dir.mktmpdir do |dir|
      Configuration.stubs(:metadata_root).returns(dir.to_s)
      connector = mock("connector")
      connector.expects(:download).once.raises(StandardError, "An error occurred")
      ConnectorClassDispatcher.stubs(:download_processor).returns(connector)

      file = mock("download_file")
      file.expects(:save_status!).with('downloading').once
      file.expects(:save_status!).with('error').once
      # FOR LOGGING
      file.expects(:id).once
      files_provider = DownloadFilesProviderMock.new([file])
      target = Download::DownloadService.new(files_provider)
      target.start
    end
  end


  private

  def download_service_thread(files_provider)
    Thread.new do
      target = Download::DownloadService.new(files_provider)
      target.start
    end
  end

  class ConnectorDownloadProcessorMock
    def initialize
      @queue = Queue.new # Used to control when the download unblocks
    end

    def download
      @queue.pop # Blocks until something is pushed into the queue
    end

    def unblock
      @queue.push(nil) # Unblocks any thread waiting on download
    end
  end
end
