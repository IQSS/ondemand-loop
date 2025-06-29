module Zenodo
  class SearchResponse
    attr_reader :page, :per_page, :items

    def initialize(json, page, per_page)
      data = JSON.parse(json)
      @page = page
      @per_page = per_page
      @items = Array(data['hits']['hits']).map do |hit|
        OpenStruct.new(id: hit['id'].to_s, title: hit.dig('metadata', 'title'))
      end
    end
  end
end
