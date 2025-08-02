# frozen_string_literal: true
require "test_helper"

class Dataverse::DownloadConnectorStatusTest < ActiveSupport::TestCase

  def setup
    @default_metadata = {
      id: '12345',
      temp_location: fixture_path('/dataverse/download_connector_status/not_found.txt.part'),
    }
    @file = DownloadFile.new
    @file.type = ConnectorType::DATAVERSE
    @file.project_id = 'project_id'
    @file.filename = 'not_found.txt'
    @file.status = FileStatus::PENDING
    @file.metadata = @default_metadata

    project = Project.new
    project.download_dir = fixture_path('/dataverse/download_connector_status')
    Project.stubs(:find).with(@file.project_id).returns(project)

  end

  test "should return 0 for missing files" do
    @file.status = FileStatus::DOWNLOADING
    @file.size = 200

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 0, target.download_progress
  end

  test "should return 0 for pending files" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::PENDING
    @file.metadata = @default_metadata

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 0, target.download_progress
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
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::SUCCESS
    @file.size = 200
    @file.metadata = @default_metadata

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 100, target.download_progress
  end

  test "should calculated percentage for downloading files" do
    file_location = fixture_path('/dataverse/download_connector_status/100bytes_file.txt')
    @default_metadata[:temp_location] = file_location
    assert File.exist?(file_location)

    @file.status = FileStatus::DOWNLOADING
    @file.size = 200
    @file.metadata = @default_metadata

    target = Dataverse::DownloadConnectorStatus.new(@file)
    assert_equal 50, target.download_progress
  end
end
