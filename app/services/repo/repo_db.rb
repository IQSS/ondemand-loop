# frozen_string_literal: true

module Repo
  class RepoDb
    include LoggingCommon
    include DateTimeCommon

    # Internal data structure representing a cached repository entry. The
    # `repo_url` attribute is included so callers can easily access the key for
    # the entry. It is purposely ignored when persisting to disk since the
    # repo URL acts as the hash key in the YAML file.
    class Entry < Struct.new(:repo_url, :type, :creation_date, :last_updated, :metadata, keyword_init: true)
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

      # Convert to a hash for persistence. `repo_url` is intentionally omitted
      # because it is already represented as the hash key in the RepoDb file.
      def to_h
        {
          type: self[:type],
          creation_date: self[:creation_date],
          last_updated: self[:last_updated],
          metadata: self[:metadata]
        }
      end
      alias_method :to_hash, :to_h
    end

    attr_reader :db_path

    def initialize(db_path:)
      @db_path = db_path
      @data = load_data
    end

    def get(repo_url)
      @data[repo_url]
    end

    def set(repo_url, type:, metadata: nil)
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      existing = @data[repo_url]
      metadata = existing&.metadata.to_h if metadata.nil?
      creation_date = existing&.creation_date || now
      @data[repo_url] = Entry.new(
        repo_url: repo_url,
        type: type.to_s,
        creation_date: creation_date,
        last_updated: Time.now.to_s,
        metadata: metadata
      )
      persist!
      log_info('Entry added', {repo_url: repo_url, type: type})
    end

    def update(repo_url, metadata:)
      raise ArgumentError, "Unknown repo url: #{repo_url}" unless @data.key?(repo_url)

      entry = @data[repo_url]
      entry.last_updated = Time.now.to_s
      entry[:metadata] ||= {}
      entry[:metadata] = entry[:metadata].merge(metadata)
      persist!
      log_info('Entry updated', { repo_url: repo_url, type: entry.type })
    end

    def delete(repo_url)
      return unless @data.key?(repo_url)

      entry = @data.delete(repo_url)
      persist!
      log_info('Entry deleted', { repo_url: repo_url, type: entry&.type })
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
      raw.each_with_object({}) do |(url, v), data|
        v = v.symbolize_keys
        data[url] = Entry.new(
          repo_url: url,
          type: v[:type],
          creation_date: v[:creation_date],
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
