module Dataverse

  class SearchResponse
    attr_reader :status, :data

    def initialize(json, page = 1, per_page = 10)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data], page, per_page)
    end

    class Data
      attr_reader :q, :total_count, :start, :items, :facets, :count_in_response, :total_count_per_object_type
      attr_reader :per_page, :page

      def initialize(data, page, per_page)
        data = data || {}
        @q = data[:q]
        @total_count = data[:total_count]
        @start = data[:start]
        @items = (data[:items] || []).map { |item| item[:type] == 'dataset' ? DatasetItem.new(item) : DataverseItem.new(item) }
        @count_in_response = data[:count_in_response]
        @page = page
        @per_page = per_page
      end

      def total_pages
        (@total_count.to_f / @per_page).ceil
      end

      def first_page?
        @page == 1
      end

      def last_page?
        @page == total_pages
      end

      def out_of_range?
        @page > total_pages
      end

      def next_page
        @page + 1 unless last_page? || out_of_range?
      end

      def prev_page
        @page - 1 unless first_page? || out_of_range?
      end

      class DatasetItem
        attr_reader :name, :type, :url, :global_id, :description, :published_at, :publisher
        attr_reader :identifier_of_dataverse, :name_of_dataverse, :citation, :storage_identifier
        attr_reader :file_count, :version_id, :version_state, :version_number, :version_minor_number, :created_at, :updated_at

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
          @version_number = item[:majorVersion]
          @version_minor_number = item[:minorVersion]
          @created_at = item[:createdAt]
          @updated_at = item[:updatedAt]
        end

        def version
          return ':draft' if version_state.to_s.downcase == 'draft'

          [version_number, version_minor_number].compact.join('.')
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
          @affiliation = item[:affiliation]
          @parent_dataverse_name = item[:parentDataverseName]
          @parent_dataverse_identifier = item[:parentDataverseIdentifier]
        end
      end
    end
  end

end