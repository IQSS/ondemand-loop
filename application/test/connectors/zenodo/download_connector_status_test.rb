require 'test_helper'

class Zenodo::DownloadConnectorStatusTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @tmp_dir = Dir.mktmpdir
    @project = create_project
    @project.download_dir = @tmp_dir
    @file = create_download_file(@project)
    @file.size = 100
    @file.filename = 'dest'
    @file.status = FileStatus::DOWNLOADING
    @file.metadata = {temp_location: File.join(@tmp_dir, 'temp')}
    File.write(@file.metadata[:temp_location], 'a' * 50)
    Project.stubs(:find).with(@file.project_id).returns(@project)

    @status = Zenodo::DownloadConnectorStatus.new(@file)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test 'calculates progress from temp file' do
    assert_equal 50, @status.download_progress
  end

  test 'returns 100 when destination exists' do
    FileUtils.touch(@file.download_location)
    assert File.exist?(@file.download_location)

    assert_equal 100, @status.download_progress
  end
end
