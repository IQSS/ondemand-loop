# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Repo
  class RepoHistory
    include DateTimeCommon
    include LoggingCommon

    class Entry
      attr_reader :repo_url, :type, :title, :note, :last_added
      attr_accessor :count

      def initialize(repo_url:, type:, title:, note:, count:, last_added:)
        raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

        @repo_url = repo_url
        @type = type
        @title = title
        @note = note
        @count = count
        @last_added = last_added
      end

      def to_h
        {
          repo_url: @repo_url,
          type: @type.to_s,
          title: @title,
          note: @note,
          count: @count,
          last_added: @last_added
        }
      end
      alias_method :to_hash, :to_h
    end

    DEFAULT_MAX_ENTRIES = 100

    attr_reader :db_path, :max_entries

    def initialize(db_path:, max_entries: DEFAULT_MAX_ENTRIES)
      @db_path = db_path
      @max_entries = max_entries
      @data = load_data.freeze
    end

    def add_repo(url, type, title: nil, note: nil)
      raise ArgumentError, "Invalid type: #{type}" unless type.is_a?(ConnectorType)

      now_time = now
      new_entry = Entry.new(repo_url: url, type: type, title: title, note: note, count: 1, last_added: now_time)
      new_data = [new_entry]

      @data.each do |e|
        if e.repo_url == url
          new_entry.count = e.count + 1
          next
        end

        new_data << e
        break if new_data.length >= max_entries
      end

      @data = new_data.freeze
      persist!
      log_info('Repo added', { repo_url: url, type: type })
      new_entry
    end

    def all
      @data
    end

    def size
      @data.size
    end

    private

    def load_data
      return [] unless File.exist?(db_path)

      raw = YAML.load_file(db_path) || []
      raw.map do |v|
        v = v.symbolize_keys
        Entry.new(
          repo_url: v[:repo_url],
          type: ConnectorType.get(v[:type]),
          title: v[:title],
          note: v[:note],
          count: v[:count] || 0,
          last_added: v[:last_added]
        )
      end
    end

    def persist!
      FileUtils.mkdir_p(File.dirname(db_path))
      payload = @data.map { |e| e.to_h.stringify_keys }
      File.write(db_path, YAML.dump(payload))
    end
  end
end
