require "test_helper"

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @new_id = SecureRandom.uuid.to_s
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def valid_json_body
    load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
  end

  def valid_json_multiple_files
    load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response_multiple_files.json'))
  end

  def incomplete_json_no_data
    load_file_fixture(File.join('dataverse', 'dataset_response', 'incomplete_no_data.json'))
  end

  test "should redirect to root path after not finding a dataverse_metadata" do
    get view_dataverse_dataset_url("random", "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataverse service error. Dataverse: https://random persistentId: random_id", flash[:error]
  end

  test "should redirect to root path after not finding a dataset" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to downloads_path
    assert_equal "Dataset not found. Dataverse: https://#{@new_id} persistentId: random_id", flash[:error]
  end

  test "should display the dataset view with the file" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(dataset)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 1 # One file is displayed on the view
  end

  test "should display the dataset view with multiple files" do
    dataset = Dataverse::DatasetResponse.new(valid_json_multiple_files)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(dataset)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 5
  end

  test "should display the dataset incomplete with no data" do
    dataset = Dataverse::DatasetResponse.new(incomplete_json_no_data)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_by_persistent_id).returns(dataset)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 0
  end

  test "should display demo.dataverse.org pages" do
    get "/view/dataverse/demo.dataverse.org/datasets/doi:10.70122/FK2/VWERU3"
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 1 # One file is displayed on the view
  end
end
