require "test_helper"

class Dataverse::CollectionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    dataverse_json = load_file_fixture(File.join('dataverse', 'collection_response', 'valid_response.json'))
    @dataverse = Dataverse::CollectionResponse.new(dataverse_json)
    search_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @search_response = Dataverse::SearchResponse.new(search_json, 1, 20)
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: ConnectorType::DATAVERSE))
    Repo::RepoResolverService.stubs(:new).returns(resolver)
  end

  test "should redirect if dataverse url is not supported" do
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: nil))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    get view_dataverse_url('invalid.host', ':root')

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.collections.url_not_supported', dataverse_url: 'https://invalid.host'), flash[:alert]
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

  test "should pass sanitized query to service" do
    service = mock('service')
    Dataverse::CollectionService.stubs(:new).returns(service)
    service.stubs(:find_collection_by_id).returns(@dataverse)
    service.expects(:search_collection_items).with(':root', has_entries(page: 1, query: 'term')).returns(@search_response)
    get view_dataverse_url("example.com", ":root", query: "term")
    assert_response :success
  end
end
