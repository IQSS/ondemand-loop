require 'test_helper'

class Dataverse::SearchCollectionItemsUrlBuilderTest < ActiveSupport::TestCase
  test 'builds default url' do
    builder = Dataverse::SearchCollectionItemsUrlBuilder.new(collection_id: ':root')
    expected = '/api/search?q=*&show_facets=true&sort=date&order=desc&per_page=10&start=0&type=dataverse&type=dataset&subtree=:root'
    assert_equal expected, builder.build
  end

  test 'builds url with query and options' do
    builder = Dataverse::SearchCollectionItemsUrlBuilder.new(
      collection_id: 'col',
      page: 2,
      per_page: 5,
      include_collections: false,
      include_datasets: true,
      query: 'term'
    )
    expected = '/api/search?q=term&show_facets=true&sort=date&order=desc&per_page=5&start=5&type=dataset&subtree=col'
    assert_equal expected, builder.build
  end

  test 'raises when collection_id missing' do
    assert_raises(RuntimeError) do
      Dataverse::SearchCollectionItemsUrlBuilder.new(collection_id: nil).build
    end
  end
end