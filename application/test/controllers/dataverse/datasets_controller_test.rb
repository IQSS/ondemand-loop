require "test_helper"

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @new_id = SecureRandom.uuid.to_s
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def dataset_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
  end

  def dataset_incomplete_json_no_data
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_data.json'))
  end

  def dataset_incomplete_json_no_metadata_blocks
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_metadata_blocks.json'))
  end

  def dataset_incomplete_json_no_license
    load_file_fixture(File.join('dataverse', 'dataset_version_response', 'incomplete_no_license.json'))
  end

  def files_valid_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
  end

  def files_incomplete_no_data_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data.json'))
  end

  def files_incomplete_no_data_file_json
    load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data_file.json'))
  end

  test "should redirect to root path after not finding a dataverse host" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises("error")
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises("error")
    get view_dataverse_dataset_url("random", "random_id")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://random persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after not finding a dataset" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(nil)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset not found. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising exception" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises("error")
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(nil)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising Unauthorized exception" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).raises(Dataverse::DataverseService::UnauthorizedException)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DataverseService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset requires authorization. Dataverse: https://#{@new_id} persistentId: random_id", flash[:alert]
  end

  test "should redirect to root path after raising Unauthorized exception only in files page" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).raises(Dataverse::DataverseService::UnauthorizedException)
    get view_dataverse_dataset_url(@new_id, "random_id")
    assert_redirected_to root_path
    assert_equal "Dataset files endpoint requires authorization. Dataverse: https://#{@new_id} persistentId: random_id page: 1", flash[:alert]
  end

  test "should display the dataset view with the file" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_valid_json)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_valid_json)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/GCN7US")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
  end

  test "should display the dataset incomplete with no data" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_incomplete_json_no_data)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_incomplete_no_data_json)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 0
  end

  test "should display the dataset incomplete with no data file" do
    dataset = Dataverse::DatasetVersionResponse.new(dataset_incomplete_json_no_data)
    Dataverse::DataverseService.any_instance.stubs(:find_dataset_version_by_persistent_id).returns(dataset)
    files_page = Dataverse::DatasetFilesResponse.new(files_incomplete_no_data_file_json)
    Dataverse::DataverseService.any_instance.stubs(:search_dataset_files_by_persistent_id).returns(files_page)
    get view_dataverse_dataset_url(@new_id, "doi:10.5072/FK2/LLIZ6Q")
    assert_response :success
    assert_select "input[type=checkbox][name='file_ids[]']", 2
  end

end
