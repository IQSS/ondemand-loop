require "test_helper"

class DownloadsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index on empty disk" do
    DetachProcess.any_instance.stubs(:start_process).returns(true)
    get downloads_url
    assert_response :success
  end

  test "should get index on disk with data" do
    DetachProcess.any_instance.stubs(:start_process).returns(true)
    populate
    get downloads_url
    assert_response :success
  end

  private

  def populate
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response_multiple_files.json'))
    dataset = Dataverse::DatasetResponse.new(valid_json)
    file_ids = [86,87,88,89,90]

    parsed_url = URI.parse("http://localhost:3000")
    service = Dataverse::DataverseService.new(parsed_url.to_s)
    download_collection = service.initialize_download_collection(dataset)
    download_collection.save

    files = service.initialize_download_files(download_collection, dataset, file_ids)
    files.each do |download_file|
      download_file.save
    end
  end
end
