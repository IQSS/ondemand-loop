require 'test_helper'

class Dataverse::Handlers::CollectionsTest < ActiveSupport::TestCase
  def setup
    @repo_url = Repo::RepoUrl.build('example.com')
    @explorer = Dataverse::Handlers::Collections.new(':root')
    dataverse_json = load_file_fixture(File.join('dataverse', 'collection_response', 'valid_response.json'))
    @collection = Dataverse::CollectionResponse.new(dataverse_json)
    search_json = load_file_fixture(File.join('dataverse', 'search_response', 'valid_response.json'))
    @search_response = Dataverse::SearchResponse.new(search_json, 1, 20)
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
    assert_includes @explorer.params_schema, :page
    assert_includes @explorer.params_schema, :query
  end

  test 'show returns collection and search results' do
    service = mock('service')
    Dataverse::CollectionService.expects(:new).with(@repo_url.server_url).returns(service)
    service.expects(:find_collection_by_id).with(':root').returns(@collection)
    service.expects(:search_collection_items).with(':root', has_entries(page: 1, query: nil)).returns(@search_response)
    res = @explorer.show(repo_url: @repo_url, page: 1)
    assert res.success?
    assert_equal @collection, res.locals[:collection]
    assert_equal @search_response, res.locals[:search_result]
  end

  test 'show returns not found message when missing data' do
    service = mock('service')
    Dataverse::CollectionService.expects(:new).returns(service)
    service.expects(:find_collection_by_id).returns(nil)
    service.expects(:search_collection_items).returns(@search_response)
    res = @explorer.show(repo_url: @repo_url)
    assert_not res.success?
    assert_equal I18n.t('connectors.dataverse.collections.show.dataverse_not_found', dataverse_url: @repo_url.server_url, id: ':root'), res.message[:alert]
  end

  test 'show returns authorization error' do
    service = mock('service')
    Dataverse::CollectionService.expects(:new).returns(service)
    service.expects(:find_collection_by_id).raises(Dataverse::CollectionService::UnauthorizedException)
    res = @explorer.show(repo_url: @repo_url)
    assert_not res.success?
    assert_equal I18n.t('connectors.dataverse.collections.show.dataverse_requires_authorization', dataverse_url: @repo_url.server_url, id: ':root'), res.message[:alert]
  end

  test 'show sanitizes query' do
    service = mock('service')
    Dataverse::CollectionService.expects(:new).returns(service)
    service.expects(:find_collection_by_id).returns(@collection)
    service.expects(:search_collection_items).with(':root', has_entries(page: 1, query: 'term')).returns(@search_response)
    res = @explorer.show(repo_url: @repo_url, query: '<b>term</b>')
    assert res.success?
  end
end
