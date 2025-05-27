require "test_helper"

class Dataverse::DataversesControllerTest < ActionDispatch::IntegrationTest

  def setup
    dataverse_json = load_file_fixture(File.join('dataverse', 'dataverse_response', 'valid_response.json'))
    @dataverse = Dataverse::DataverseResponse.new(dataverse_json)
    search_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @search_response = Dataverse::SearchResponse.new(search_json, 1, 20)
  end

  test "should redirect to root path after not finding a dataverse" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).raises("error")
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).raises("error")
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse service error. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after finding an unauthorized dataverse" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).raises(Dataverse::CollectionService::UnauthorizedException)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse requires authorization. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding neither dataverse nor dataverse results" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding dataverse response" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).returns(nil)
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should redirect to root path after not finding search response" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).returns(@dataverse)
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).returns(nil)
    get view_dataverse_url("example.com", ":root")
    assert_redirected_to root_path
    assert_equal "Dataverse not found. Dataverse: https://example.com Id: :root", flash[:alert]
  end

  test "should display the datavers view with the results" do
    Dataverse::CollectionService.any_instance.stubs(:find_collection_by_id).returns(@dataverse)
    Dataverse::CollectionService.any_instance.stubs(:search_collection_items).returns(@search_response)
    get view_dataverse_url("example.com", ":root")
    assert_response :success
  end

end
