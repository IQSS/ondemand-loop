# frozen_string_literal: true

require "json"

module Dataverse
  class DatasetFilesResponse
    include ActsAsPage
    attr_reader :status, :data

    def initialize(json, page: 1, per_page: 10)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @page = page
      @per_page = per_page
      all_data = (parsed[:data] || []).map { |file| DatasetFile.new(file) }

      if parsed[:totalCount]
        @total_count = parsed[:totalCount]
        @data = all_data
      else
        # Manual pagination for APIs without native support
        @total_count = all_data.size
        @data = all_data.slice(offset, @per_page) || []
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

      class DataFile
        attr_reader :id, :filename, :content_type, :friendly_type, :storage_identifier, :filesize, :md5, :publication_date
        attr_reader :original_filename, :original_content_type, :original_filesize

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

          @original_filename = data_file[:originalFileName]
          @original_content_type = data_file[:originalFileFormat]
          @original_filesize = data_file[:originalFileSize]
        end
      end
    end
  end
end