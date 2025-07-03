module Dataverse
  class SearchDatasetFilesUrlBuilder
    attr_accessor :persistent_id, :version, :page, :per_page

    def initialize(persistent_id:, version: ':latest-published', page: 1, per_page: 10, query: nil)
      @persistent_id = persistent_id
      @version = version
      @page = page
      @per_page = per_page
      @query = query
    end

    def build
      raise 'persistent_id is required' if persistent_id.nil? || persistent_id.strip.empty?

      offset = (page - 1) * per_page

      path = "/api/datasets/:persistentId/versions/#{version}/files"
      query_params = {
        persistentId: persistent_id,
        offset: offset,
        limit: per_page
      }
      query_params[:searchText] = @query if @query

      query_string = Rack::Utils.build_query(query_params)
      URI::Generic.build(path: path, query: query_string).to_s
    end
  end
end