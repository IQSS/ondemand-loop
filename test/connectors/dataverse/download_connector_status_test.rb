# frozen_string_literal: true
require "test_helper"

class Dataverse::DownloadConnectorStatusTest < ActiveSupport::TestCase

  def setup
    @file = DownloadFile.new
    @file.type = ConnectorType::DATAVERSE
    @file.project_id = 'project_id'
    @file.filename = 'not_found.txt'
    @file.status = FileStatus::PENDING

    project = Project.new
    project.download_dir = fixture_path('/dataverse/download_connector_status')
    Project.stubs(:find).with(@file.project_id).returns(project)

  end

  test "should return 0 for missing files" do
    @file.status = FileStatus::DOWNLOADING
    @file.size = 200
    refute File.exist?(@file.download_location)
    refute File.exist?(@file.download_tmp_location)

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 0, target.download_progress
  end

  test "should calculated percentage for pending files when tmp file exists" do
    @file.status = FileStatus::PENDING
    @file.filename = '100bytes_partial_file.txt'
    @file.size = 200
    assert File.exist?(@file.download_tmp_location)
    refute File.exist?(@file.download_location)

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 50, target.download_progress
  end

  test "should return 100 if the destination file already created" do
    @file.status = FileStatus::DOWNLOADING
    @file.filename = '100bytes_file.txt'
    @file.size = 200
    assert File.exist?(@file.download_location)

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 100, target.download_progress
  end

  test "should return 100 for completed files" do
    @file.status = FileStatus::SUCCESS
    @file.filename = 'completed_file.txt'
    @file.size = 100
    assert File.exist?(@file.download_location)
    refute File.exist?(@file.download_tmp_location)

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 100, target.download_progress
  end

  test "should calculated percentage for downloading files when tmp file exists" do
    @file.status = FileStatus::DOWNLOADING
    @file.filename = '100bytes_partial_file.txt'
    @file.size = 200
    assert File.exist?(@file.download_tmp_location)

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 50, target.download_progress
  end
end
