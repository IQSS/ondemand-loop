require "test_helper"

class DownloadsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index" do
    get downloads_url
    assert_response :success
  end
end
