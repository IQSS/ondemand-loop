# frozen_string_literal: true

require "json"

module Dataverse
  class DatasetVersionResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    def metadata_field(field_name)
      field = data.metadata_blocks.citation.fields.find{|f| f.type_name == field_name}
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

    def version
      return ':draft' if data.version_state.to_s.downcase == 'draft'

      [data.version_number, data.version_minor_number].compact.join('.')
    end

    class Data
      attr_reader :id, :publication_date, :dataset_id, :dataset_persistent_id,
                  :version_number, :version_minor_number, :version_state,
                  :license, :metadata_blocks, :parents

      def initialize(data)
        data = data || {}
        @id = data[:id]
        @publication_date = data[:publicationDate]
        @dataset_id = data[:datasetId]
        @dataset_persistent_id = data[:datasetPersistentId]
        @version_number = data[:versionNumber]
        @version_minor_number = data[:versionMinorNumber]
        @version_state = data[:versionState]
        @license = License.new(data[:license])
        @metadata_blocks = MetadataBlocks.new(data[:metadataBlocks])
        @parents = []
        parent = data[:isPartOf]
        while parent
          p = { name: parent[:displayName], type: parent[:type], identifier: parent[:identifier] }
          @parents << p
          parent = parent[:isPartOf]
        end
        @parents.reverse!
      end

      class License
        attr_reader :name, :uri, :icon_uri

        def initialize(license)
          license_hash = license.is_a?(Hash) ? license : { name: license }
          @name = license_hash[:name]
          @uri = license_hash[:uri]
          @icon_uri = license_hash[:iconUri]
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
    end
  end
end