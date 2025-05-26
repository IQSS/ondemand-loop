module Dataverse
  class MyDataverseCollectionsResponse
    include ActsAsPage
    attr_reader :status, :items

    def initialize(json, page: 1, per_page: 100)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:success] == true ? "OK" : "ERROR"
      @items = parsed.dig(:data, :items).map { |item| DataverseItem.new(item) }
      @total_count = parsed.dig(:data, :total_count)
      @page = page
      @per_page = per_page
    end

    class DataverseItem
      attr_reader :name, :type, :url, :identifier, :published_at, :publication_statuses, :affiliation
      attr_reader :parent_dataverse_name, :parent_dataverse_identifier

      def initialize(item)
        item = item || {}
        @name = item[:name]
        @type = item[:type]
        @url = item[:url]
        @identifier = item[:identifier]
        @published_at = item[:published_at]
        #@publication_statuses = item[:publicationStatuses]
        @affiliation = item[:affiliation]
        @parent_dataverse_name = item[:parentDataverseName]
        @parent_dataverse_identifier = item[:parentDataverseIdentifier]
      end
    end
  end
end