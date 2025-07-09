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
    url = FluentUrl.new('')
              .add_path('api')
              .add_path('datasets')
              .add_path(':persistentId')
              .add_path('versions')
              .add_path(version)
              .add_path('files')
              .add_param('persistentId', persistent_id)
              .add_param('offset', offset)
              .add_param('limit', per_page)
    url.add_param('searchText', @query) if @query
    url.to_s
    end
  end
end