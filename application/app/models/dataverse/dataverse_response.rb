module Dataverse
  class DataverseResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :id, :alias, :name, :description, :is_facet_root

      def initialize(data)
        data = data || {}
        @id = data[:id]
        @alias = data[:alias]
        @name = data[:name]
        @description = data[:description]
        @is_facet_root = data[:isFacetRoot]
      end
    end
  end
end