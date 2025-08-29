# frozen_string_literal: true

require 'addressable'

module Zenodo
  class Deposition
    FileItem = Struct.new(:id, :filename, :filesize, :checksum, :download_link, :download_url, keyword_init: true)

    attr_reader :id, :record_id, :title, :description, :publication_date,
                :files, :file_count, :bucket_url, :submitted, :raw

    def initialize(raw)
      @raw = raw || {}
      @id = raw['id'].to_s
      @record_id = raw['record_id']&.to_s
      @submitted = raw['submitted']
      @bucket_url = raw.dig('links', 'bucket')
      @title = raw.dig('metadata', 'title') || raw['title'] || 'Untitled'
      @description = raw.dig('metadata', 'description') || raw['description']
      @publication_date = raw.dig('metadata', 'publication_date') || raw['created']
      @files = Array(raw['files']).map do |f|
        raw_url = f.dig('links', 'download') || f.dig('links', 'self')
        encoded_url = raw_url && encode_url_path(raw_url)

        FileItem.new(
          id: f['id'].to_s,
          filename: f['filename'] || f['key'],
          filesize: f['filesize'] || f['size'],
          checksum: f['checksum'],
          download_link: raw_url,
          download_url: encoded_url
        )
      end
      @file_count = @files.count
    end

    def draft?
      submitted == false
    end

    def version
      draft? ? 'draft' : 'published'
    end

    def to_s
      "deposition{id=#{id} files=#{file_count} draft=#{draft?}}"
    end

    private

    def encode_url_path(url)
      Addressable::URI.parse(url).normalize.to_s
    rescue Addressable::URI::InvalidURIError => e
      raise "Invalid URL from Zenodo: #{url.inspect} (#{e.message})"
    end
  end
end
