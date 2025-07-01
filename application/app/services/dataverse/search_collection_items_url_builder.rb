module Dataverse
  # Builds the relative URL for searching items within a collection.
  class SearchCollectionItemsUrlBuilder
    attr_accessor :collection_id, :page, :per_page,
                  :include_collections, :include_datasets, :query

    def initialize(collection_id:, page: 1, per_page: 10,
                   include_collections: true, include_datasets: true, query: nil)
      @collection_id = collection_id
      @page = page
      @per_page = per_page
      @include_collections = include_collections
      @include_datasets = include_datasets
      @query = query
    end

    def build
      raise 'collection_id is missing' unless collection_id

      start = (page - 1) * per_page
      search_query = query.present? ? CGI.escape(query.to_s) : '*'
      url = "/api/search?q=#{search_query}&show_facets=true&sort=date&order=desc"
      url += "&per_page=#{per_page}&start=#{start}"
      url += "&type=dataverse" if include_collections
      url += "&type=dataset" if include_datasets
      url += "&subtree=#{collection_id}"
      url
    end
  end
end