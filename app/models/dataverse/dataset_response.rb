# frozen_string_literal: true

require "json"

module Dataverse
  class DatasetResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :id, :identifier, :persistent_url, :publisher, :publication_date, :dataset_type, :latest_version

      def initialize(data)
        @id = data[:id]
        @identifier = data[:identifier]
        @persistent_url = data[:persistentUrl]
        @publisher = data[:publisher]
        @publication_date = data[:publicationDate]
        @dataset_type = data[:datasetType]
        @latest_version = Version.new(data[:latestVersion])
      end

      class Version
        attr_reader :id, :version_number, :version_state, :license, :files

        def initialize(version)
          @id = version[:id]
          @version_number = version[:versionNumber]
          @version_state = version[:versionState]
          @license = License.new(version[:license])
          @files = version[:files].map { |file| DatasetFile.new(file) }
        end

        class License
          attr_reader :name, :uri, :icon_uri

          def initialize(license)
            @name = license[:name]
            @uri = license[:uri]
            @icon_uri = license[:iconUri]
          end
        end

        class DatasetFile
          attr_reader :label, :restricted, :data_file

          def initialize(file)
            @label = file[:label]
            @restricted = file[:restricted]
            @data_file = DataFile.new(file[:dataFile])
          end

          class DataFile
            attr_reader :id, :filename, :content_type, :filesize, :md5

            def initialize(data_file)
              @id = data_file[:id]
              @filename = data_file[:filename]
              @content_type = data_file[:contentType]
              @filesize = data_file[:filesize]
              @md5 = data_file[:md5]
            end
          end
        end
      end
    end
  end
end