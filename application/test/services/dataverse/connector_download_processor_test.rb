# frozen_string_literal: true

require "test_helper"

class Dataverse::ConnectorDownloadProcessorTest < ActiveSupport::TestCase

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)

    @project = create_download_project
    @project.save

    @file = create_download_file(@project)
    @file.id = "file-123"
    @file.metadata = {
      id: "456",
      filename: "data.csv",
      md5: Digest::MD5.hexdigest("test content"),
      dataverse_url: "http://example.com",
      download_url: nil,
      download_location: nil,
      temp_location: nil,
    }

    @download_path = File.join(@project.download_dir, "data.csv")
    @temp_path = "#{@download_path}.part"

    File.write(@download_path, "test content") # for MD5 match

    @processor = Dataverse::ConnectorDownloadProcessor.new(@file)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should return success response when download and md5 match" do
    mock_downloader = mock("downloader")
    Download::BasicHttpRubyDownloader
      .expects(:new).with("http://example.com/api/access/datafile/456",
                          @download_path,
                          @temp_path
                          ).returns(mock_downloader)

    mock_downloader.expects(:download).yields(nil)

    response = @processor.download
    assert_equal FileStatus::SUCCESS, response.status
    assert_match "download completed", response.message
  end

  test "should return cancelled response if download is cancelled" do
    mock_downloader = mock("downloader")
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.expects(:download).yields(nil)

    @processor.instance_variable_set(:@cancelled, true)
    response = @processor.download

    assert_equal FileStatus::CANCELLED, response.status
    assert_match "cancelled", response.message
  end

  test "should return error response if md5 does not match" do
    File.write(@download_path, "bad content") # Wrong checksum

    mock_downloader = mock("downloader")
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.expects(:download).yields(nil)

    response = @processor.download

    assert_equal FileStatus::ERROR, response.status
    assert_match "md5 check failed", response.message
  end

  test "should set cancelled true when process receives matching request" do
    request = OpenStruct.new(body: OpenStruct.new(file_id: "file-123"))

    result = @processor.process(request)

    assert_equal true, @processor.cancelled
    assert_equal "cancellation requested", result[:message]
  end

  test "should ignore request if file id does not match" do
    request = OpenStruct.new(body: OpenStruct.new(file_id: "other-id"))

    result = @processor.process(request)

    assert_nil result
    assert_equal false, @processor.cancelled
  end

  test "should update file metadata with download url and locations" do
    mock_downloader = mock("downloader")
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.stubs(:download).yields(nil)

    expected_url = "http://example.com/api/access/datafile/456"
    expected_location = File.join(@project.download_dir, "data.csv")
    expected_temp = "#{expected_location}.part"

    @file.expects(:update).with do |arg|
      metadata = arg[:metadata]
      metadata["download_url"] == expected_url &&
        metadata["download_location"] == expected_location &&
        metadata["temp_location"] == expected_temp
    end

    @processor.download
  end
end
