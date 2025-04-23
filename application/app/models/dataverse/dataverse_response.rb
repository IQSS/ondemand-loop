module Dataverse
  class DataverseResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :id, :alias, :name, :description, :is_facet_root, :parents

      def initialize(data)
        data = data || {}
        @id = data[:id]
        @alias = data[:alias]
        @name = data[:name]
        @description = data[:description]
        @is_facet_root = data[:isFacetRoot]
        @parents = []
        parent = data[:isPartOf]
        while parent
          p = { name: parent[:displayName], type: parent[:type], identifier: parent[:identifier] }
          @parents << p
          parent = parent[:isPartOf]
        end
        @parents.reverse!
      end
    end
  end
end