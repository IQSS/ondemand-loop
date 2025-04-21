require "test_helper"

class Dataverse::DataversesControllerTest < ActionDispatch::IntegrationTest

  def setup
    dataverse_json = load_file_fixture(File.join('dataverse', 'dataverse_response', 'valid_response.json'))
    @dataverse = Dataverse::DataverseResponse.new(dataverse_json)
    search_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @search_response = Dataverse::SearchResponse.new(search_json, 1, 20)
  end

  test "should redirect to root path after not finding a dataverse" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataverse_by_id).raises("error")
    Dataverse::DataverseService.any_instance.stubs(:search_dataverse_items).raises("error")
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://example.com Id: :root", flash[:error]
  end

  test "should redirect to root path after not finding neither dataverse nor dataverse results" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataverse_by_id).returns(nil)
    Dataverse::DataverseService.any_instance.stubs(:search_dataverse_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:error]
  end

  test "should redirect to root path after not finding dataverse response" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataverse_by_id).returns(nil)
    Dataverse::DataverseService.any_instance.stubs(:search_dataverse_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:error]
  end

  test "should redirect to root path after not finding search response" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataverse_by_id).returns(@dataverse)
    Dataverse::DataverseService.any_instance.stubs(:search_dataverse_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:error]
  end

  test "should display the datavers view with the results" do
    Dataverse::DataverseService.any_instance.stubs(:find_dataverse_by_id).returns(@dataverse)
    Dataverse::DataverseService.any_instance.stubs(:search_dataverse_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_response :success
  end

end
