module Dataverse
  class DatasetVersionsResponse
    attr_reader :status, :versions

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @versions = (parsed[:data] || []).map do |v|
        Data.new(v)
      end
    end

    class Data
      attr_reader :persistent_id, :version_number, :version_minor_number,
                  :version_state, :last_update_time, :create_time,
                  :publication_date

      def initialize(data)
        data ||= {}
        @persistent_id = data[:datasetPersistentId]
        @version_number = data[:versionNumber]
        @version_minor_number = data[:versionMinorNumber]
        @version_state = data[:versionState]
        @last_update_time = data[:lastUpdateTime]
        @create_time = data[:createTime]
        @publication_date = data[:publicationDate]
      end

      def version
        return ':draft' if version_state.to_s.casecmp('DRAFT').zero?

        [version_number, version_minor_number].compact.join('.')
      end
    end
  end
end
