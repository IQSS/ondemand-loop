require 'test_helper'

module Dataverse
  class SearchDatasetFilesUrlBuilderTest < ActiveSupport::TestCase
    def test_builds_url_with_default_values
      builder = SearchDatasetFilesUrlBuilder.new(
        persistent_id: 'doi:10.5072/FK2/ABC123'
      )
      url = builder.build

      expected = "/api/datasets/:persistentId/versions/:latest-published/files?" \
        "limit=20&offset=0&persistentId=doi%3A10.5072%2FFK2%2FABC123"
      assert_equal expected, url
    end

    def test_builds_url_with_custom_page_and_per_page
      builder = SearchDatasetFilesUrlBuilder.new(
        persistent_id: 'doi:10.5072/FK2/XYZ456',
        page: 3,
        per_page: 25
      )
      url = builder.build

      expected = "/api/datasets/:persistentId/versions/:latest-published/files?" \
        "limit=25&offset=50&persistentId=doi%3A10.5072%2FFK2%2FXYZ456"
      assert_equal expected, url
    end

    def test_builds_url_with_custom_version
      builder = SearchDatasetFilesUrlBuilder.new(
        persistent_id: 'doi:10.5072/FK2/XYZ456',
        version: '2.1'
      )
      url = builder.build

      expected = "/api/datasets/:persistentId/versions/2.1/files?" \
        "limit=20&offset=0&persistentId=doi%3A10.5072%2FFK2%2FXYZ456"
      assert_equal expected, url
    end

    def test_builds_url_with_query
      builder = SearchDatasetFilesUrlBuilder.new(
        persistent_id: 'doi:10.5072/FK2/QUERY123',
        query: 'climate change'
      )
      url = builder.build

      expected = "/api/datasets/:persistentId/versions/:latest-published/files?" \
        "limit=20&offset=0&persistentId=doi%3A10.5072%2FFK2%2FQUERY123&searchText=climate%20change"
      assert_equal expected, url
    end

    def test_raises_error_if_persistent_id_blank
      assert_raises(RuntimeError, 'persistent_id is required') do
        SearchDatasetFilesUrlBuilder.new(persistent_id: '').build
      end
    end

    def test_raises_error_if_persistent_id_nil
      assert_raises(RuntimeError, 'persistent_id is required') do
        SearchDatasetFilesUrlBuilder.new(persistent_id: nil).build
      end
    end
  end
end
