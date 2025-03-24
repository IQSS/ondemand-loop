require "test_helper"

class DownloadsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    Rake.application.rake_require("tasks/populate")
    Rake::Task.define_task(:environment)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index on empty disk" do
    get downloads_url
    assert_response :success
    assert_select "div.col-md-9 > div.row", count: 0
  end

  test "should get index on disk with data" do
    task = Rake::Task["dev:populate"]
    task.invoke
    get downloads_url
    assert_response :success
    assert_select "div.col-md-9 > div.row", count: 1
    assert_select "div.col-md-9 > div.row > div.card > div.card", count: 4
  end
end
