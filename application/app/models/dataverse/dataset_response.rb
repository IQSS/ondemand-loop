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

    def files
      data.latest_version.files || []
    end

    def files_by_ids(ids)
      ids = Array(ids)
      ids = ids.map { |id| id.to_i }
      files.select { |f| ids.include?(f.data_file.id.to_i) }
    end

    def metadata_field(field_name)
      field = data.latest_version.metadata_blocks.citation.fields.find{|f| f.type_name == field_name}
      field.value if field
    end

    def authors
      authors = metadata_field("author")
      return "" if authors.nil?
      authors.map do |author|
        author_name = author[:authorName] || {}
        author_name[:value].to_s
      end.join(" | ")
    end

    def description
      descriptions = metadata_field("dsDescription")
      return "" if descriptions.nil?
      descriptions.map do |desc|
        description_value = desc[:dsDescriptionValue] ||{}
        description_value[:value].to_s
      end.join(" ")
    end

    def subjects
      subjects = metadata_field("subject")
      return "" if subjects.nil?
      subjects.join(", ")
    end

    class Data
      attr_reader :id, :identifier, :persistent_url, :publisher, :publication_date, :dataset_type, :latest_version
      attr_reader :parents

      def initialize(data)
        data = data || {}
        @id = data[:id]
        @identifier = data[:identifier]
        @persistent_url = data[:persistentUrl]
        @publisher = data[:publisher]
        @publication_date = data[:publicationDate]
        @dataset_type = data[:datasetType]
        @latest_version = Version.new(data[:latestVersion])
        @parents = []
        parent = data[:isPartOf]
        while parent
          p = { name: parent[:displayName], type: parent[:type], identifier: parent[:identifier] }
          @parents << p
          parent = parent[:isPartOf]
        end
        @parents.reverse!
      end

      class Version
        attr_reader :id, :dataset_id, :dataset_persistent_id, :version_number, :version_state, :license, :files,
                    :metadata_blocks

        def initialize(version)
          version = version || {}
          @id = version[:id]
          @dataset_id = version[:datasetId]
          @dataset_persistent_id = version[:datasetPersistentId]
          @version_number = version[:versionNumber]
          @version_state = version[:versionState]
          @license = License.new(version[:license])
          @metadata_blocks = MetadataBlocks.new(version[:metadataBlocks])
          @files = (version[:files] || []).map { |file| DatasetFile.new(file) }
        end

        class License
          attr_reader :name, :uri, :icon_uri

          # TODO: GOT AN ERROR in https://abacus.library.ubc.ca persistentId: hdl:11272.1/AB2/0HWPT7
          # LICENCE IS A STRING WITH "NONE"
          def initialize(license)
            license = { name: license } if license.is_a?(String)
            license = license || {}
            @name = license[:name]
            @uri = license[:uri]
            @icon_uri = license[:iconUri]
          end
        end

        class MetadataBlocks
          attr_reader :citation
          def initialize(metadata_blocks)
            metadata_blocks = metadata_blocks || {}
            @citation = Citation.new(metadata_blocks[:citation])
          end

          class Citation
            attr_reader :name, :fields
            def initialize(citation)
              citation = citation || {}
              @name = citation[:name]
              @fields = (citation[:fields] || []).map { |field| CitationField.new(field) }
            end

            class CitationField
              attr_reader :type_name, :multiple, :type_class, :value
              def initialize(field)
                field = field || {}
                @type_name = field[:typeName]
                @multiple = field[:multiple]
                @type_class = field[:typeClass]
                @value = field[:value]
              end
            end
          end

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

          class DataFile
            attr_reader :id, :filename, :content_type, :friendly_type, :storage_identifier, :filesize, :md5, :publication_date

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
            end
          end
        end
      end
    end
  end
end