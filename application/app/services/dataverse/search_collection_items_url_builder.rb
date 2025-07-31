module Dataverse
  # Builds the relative URL for searching items within a collection.
  class SearchCollectionItemsUrlBuilder
    attr_accessor :collection_id, :page, :per_page,
                  :include_collections, :include_datasets, :query

    def initialize(collection_id:, page: 1, per_page: nil,
                   include_collections: true, include_datasets: true, query: nil)
      @collection_id = collection_id
      @page = page
      @per_page = per_page || Configuration.default_pagination_items
      @include_collections = include_collections
      @include_datasets = include_datasets
      @query = query
    end

    def build
      raise 'collection_id is missing' unless collection_id

      start = (page - 1) * per_page
      query_params = {
        q: query.present? ? query.to_s : '*',
        show_facets: true,
        sort: 'date',
        order: 'desc',
        per_page: per_page,
        start: start,
        subtree: collection_id
      }

      types = []
      types << 'dataverse' if include_collections
      types << 'dataset' if include_datasets
      query_params[:type] = types unless types.empty?

      url = FluentUrl.new('')
              .add_path('api')
              .add_path('search')
      query_params.each { |k, v| url.add_param(k, v) }
      url.to_s
    end
  end
end