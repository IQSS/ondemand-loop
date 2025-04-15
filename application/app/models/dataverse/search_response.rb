module Dataverse

  class SearchResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :q, :total_count, :start, :items, :facets, :count_in_response, :total_count_per_object_type

      def initialize(data)
        data = data || {}
        @q = data[:q]
        @total_count = data[:total_count]
        @start = data[:start]
        @items = (data[:items] || []).map do |item|
          return DatasetItem.new(item) if item[:type] == 'dataset'
          return DataverseItem.new(item) if item[:type] == 'dataverse'
          nil
        end.compact
        #@facets = data[:facets]
        @count_in_response = data[:count_in_response]
        #@total_count_per_object_type = data[:total_count_per_object_type]
      end

      class DatasetItem
        attr_reader :name, :type, :url, :global_id, :description, :published_at, :publisher
        attr_reader :identifier_of_dataverse, :name_of_dataverse, :citation, :storage_identifier
        attr_reader :file_count, :version_id, :version_state, :created_at, :updated_at

        def initialize(item)
          item = item || {}
          @name = item[:name]
          @type = item[:type]
          @url = item[:url]
          @global_id = item[:global_id]
          @description = item[:description]
          @published_at = item[:published_at]
          @publisher = item[:publisher]
          @identifier_of_dataverse = item[:identifier_of_dataverse]
          @name_of_dataverse = item[:name_of_dataverse]
          @citation = item[:citation]
          @storage_identifier = item[:storageIdentifier]
          @file_count = item[:fileCount]
          @version_id = item[:versionId]
          @version_state = item[:versionState]
          @created_at = item[:createdAt]
          @updated_at = item[:updatedAt]
        end
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

end