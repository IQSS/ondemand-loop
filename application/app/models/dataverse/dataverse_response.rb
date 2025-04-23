module Dataverse
  class DataverseResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :id, :alias, :name, :description, :is_facet_root, :parent_identifier, :parent_name

      def initialize(data)
        data = data || {}
        @id = data[:id]
        @alias = data[:alias]
        @name = data[:name]
        @description = data[:description]
        @is_facet_root = data[:isFacetRoot]
        unless @is_facet_root
          is_part_of = data[:isPartOf] || {}
          @parent_name = is_part_of[:displayName]
          @parent_identifier = is_part_of[:identifier]
        end
      end
    end
  end
end