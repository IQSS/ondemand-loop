# frozen_string_literal: true

module Repo
  class RepoDb
    include LoggingCommon

    class Entry < Struct.new(:type, :last_updated, :metadata, keyword_init: true)
      def type
        ConnectorType.get(self[:type])
      end

      def metadata
        OpenStruct.new(self[:metadata] || {})
      end

      def type=(value)
        raise ArgumentError, "Invalid type: #{value}" unless value.is_a?(ConnectorType)
        self[:type] = value.to_s
      end
    end

    attr_reader :db_path

    def initialize(db_path:)
      @db_path = db_path
      @data = load_data
    end

    def get(domain)
      @data[domain]
    end

    def set(domain, type:, metadata: nil)
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      metadata = @data[domain]&[:metadata] || {} if metadata.nil?
      @data[domain] = Entry.new(
        type: type.to_s,
        last_updated: Time.now.to_s,
        metadata: metadata
      )
      persist!
      log_info('Entry added', {domain: domain, type: type})
    end

    def update(domain, metadata:)
      raise ArgumentError, "Unknown domain: #{domain}" unless @data.key?(domain)

      entry = @data[domain]
      entry.last_updated = Time.now.to_s
      entry[:metadata] ||= {}
      entry[:metadata] = entry[:metadata].merge(metadata)
      persist!
      log_info('Entry updated', { domain: domain, type: entry.type })
    end

    def delete(domain)
      @data.delete(domain)
    end

    def size
      @data.size
    end

    def all
      @data
    end

    private

    def load_data
      return {} unless File.exist?(db_path)

      raw = YAML.load_file(db_path) || {}
      raw.transform_values do |v|
        v = v.symbolize_keys
        Entry.new(
          type: v[:type],
          last_updated: v[:last_updated],
          metadata: v[:metadata] || {}
        )
      end
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(db_path))
      File.write(db_path, YAML.dump(@data.transform_values(&:to_h)))
    end
  end
end
