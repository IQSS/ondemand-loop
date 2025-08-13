require 'test_helper'

class Upload::UploadServiceTest < ActiveSupport::TestCase
  include ModelHelper

  class UploadFilesProviderMock
    def initialize(data)
      @data = data
      @from = 0
    end

    def pending_files
      (@data[@from..-1] || []).tap { @from += 1 }
    end

    def processing_files
      []
    end
  end

  class ProcessorMock
    def initialize(result)
      @result = result
    end

    def upload
      @result
    end
  end

  test 'start processes files and updates status' do
    project = create_project
    bundle = create_upload_bundle(project)
    file = create_upload_file(project, bundle)
    data = OpenStruct.new(file: file, project: project, upload_bundle: bundle)
    provider = UploadFilesProviderMock.new([data])
    processor = ProcessorMock.new(OpenStruct.new(status: FileStatus::SUCCESS))
    ConnectorClassDispatcher.stubs(:upload_processor).returns(processor)
    now_time = file_now

    file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::UPLOADING).once
    file.expects(:update).with(end_date: now_time, status: FileStatus::SUCCESS).once

    service = Upload::UploadService.new(provider)
    service.stubs(:now).returns(now_time)
    service.start
    assert_equal 1, service.stats[:completed]
  end

  test 'start handles errors and marks file' do
    project = create_project
    bundle = create_upload_bundle(project)
    file = create_upload_file(project, bundle)
    data = OpenStruct.new(file: file, project: project, upload_bundle: bundle)
    provider = UploadFilesProviderMock.new([data])
    processor = ProcessorMock.new(nil)
    ConnectorClassDispatcher.stubs(:upload_processor).returns(processor)
    def processor.upload; raise 'boom'; end

    now_time = file_now
    file.expects(:update).with(start_date: now_time, end_date: nil, status: FileStatus::UPLOADING).once
    file.expects(:update).with(end_date: now_time, status: FileStatus::ERROR).once

    service = Upload::UploadService.new(provider)
    service.stubs(:now).returns(now_time)
    service.start
    assert_equal 1, service.stats[:completed]
  end
end
