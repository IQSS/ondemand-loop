# frozen_string_literal: true

require "json"
require "date"

module Dataverse
  class DatasetFilesResponse
    include ActsAsPage
    attr_reader :status, :data

    def initialize(json, page: 1, per_page: 10, query: nil, dataset_total: nil)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @page = page
      @per_page = per_page
      @query = query
      all_data = (parsed[:data] || []).map { |file| DatasetFile.new(file) }

      # Determine total count and pagination approach:
      # 1. If API provides totalCount - use it (modern API with built-in pagination)
      # 2. If dataset_total provided - use it (caller knows the total file count)
      # 3. Fallback to all_data.size (unknown total, use what we received)
      @total_count = parsed[:totalCount] || dataset_total || all_data.size
      @data = all_data

      # When all_data.size equals @total_count, it means the API returned ALL files
      # (no server-side pagination), so we need to manually paginate the results
      if all_data.size == @total_count
        @data = all_data.slice(offset, per_page) || []
      end
    end

    def files
      data || []
    end

    def files_by_ids(ids)
      ids = Array(ids)
      ids = ids.map { |id| id.to_i }
      files.select { |f| ids.include?(f.data_file.id.to_i) }
    end

    class DatasetFile
      attr_reader :label, :directory_label, :restricted, :data_file

      def initialize(file)
        file = file || {}
        @label = file[:label]
        @directory_label = file[:directoryLabel]
        @restricted = file[:restricted]
        @data_file = DataFile.new(file[:dataFile])
      end

      def full_filename
        filename = data_file&.original_filename || data_file&.filename
        File.join('/', directory_label.to_s, filename.to_s)
      end

      def filesize
        data_file.original_filesize || data_file.filesize
      end

      def content_type
        data_file.original_content_type || data_file.content_type
      end

      def public?
        !restricted && !data_file.embargoed?
      end

      class DataFile
        attr_reader :id, :filename, :content_type, :friendly_type, :storage_identifier, :filesize, :md5, :publication_date
        attr_reader :original_filename, :original_content_type, :original_filesize, :embargo

        def initialize(data_file)
          data_file = data_file || {}
          @id = data_file[:id]
          @filename = data_file[:filename]
          @content_type = data_file[:contentType]
          @friendly_type = data_file[:friendlyType]
          @storage_identifier = data_file[:storageIdentifier]
          @filesize = data_file[:filesize]
          @md5 = data_file[:md5]
          @publication_date = data_file[:publicationDate]

          @embargo = data_file[:embargo] ? Embargo.new(data_file[:embargo]) : nil

          @original_filename = data_file[:originalFileName]
          @original_content_type = data_file[:originalFileFormat]
          @original_filesize = data_file[:originalFileSize]
        end

        def embargoed?
          embargo&.active?
        end

        class Embargo
          attr_reader :date_available, :reason

          def initialize(embargo)
            embargo ||= {}
            @date_available = embargo[:dateAvailable]
            @reason = embargo[:reason]
          end

          def active?
            return false if date_available.nil?
            Date.parse(date_available) > Date.current
          rescue ArgumentError
            false
          end
        end
      end
    end
  end
end