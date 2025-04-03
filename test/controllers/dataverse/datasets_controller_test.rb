require "test_helper"

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    @new_id = SecureRandom.uuid.to_s
    dataverse_metadata = Dataverse::DataverseMetadata.new
    dataverse_metadata.id = @new_id
    dataverse_metadata.hostname = 'localhost'
    dataverse_metadata.port = 443
    dataverse_metadata.scheme = 'https'
    dataverse_metadata.save
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def valid_json_body
    load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
  end

  test "should redirect to root path after not finding a dataverse_metadata" do
    get view_dataverse_dataset_url("random", "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataverse host metadata not found", flash[:error]
  end

  test "should redirect to root path after not finding a dataset" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataset not found", flash[:error]
  end

  test "should display the dataset view with the file" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(dataset)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 1 # One file is displayed on the view
  end
end
