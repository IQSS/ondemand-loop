# frozen_string_literal: true

require 'addressable'

module Zenodo
  class DepositionResponse
    FileItem = Struct.new(:id, :filename, :filesize, :checksum, :download_link, :download_url, keyword_init: true)

    attr_reader :id, :title, :description, :publication_date,
                :files, :file_count, :bucket_url, :submitted, :raw

    def initialize(response_body)
      @raw = JSON.parse(response_body)

      @id = @raw['id'].to_s
      @submitted = @raw['submitted']
      @bucket_url = @raw.dig('links', 'bucket')
      @title = @raw.dig('metadata', 'title') || 'Untitled'
      @description = @raw.dig('metadata', 'description')
      @publication_date = @raw.dig('metadata', 'publication_date')
      @files = Array(@raw['files']).map do |f|
        raw_url = f.dig('links', 'self')
        encoded_url = encode_url_path(raw_url)

        FileItem.new(
          id: f['id'].to_s,
          filename: f['key'],
          filesize: f['size'],
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
