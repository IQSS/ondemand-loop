require 'addressable'

module Zenodo
  class RecordResponse
    FileItem = Struct.new(:id, :filename, :filesize, :checksum, :download_link, :download_url, keyword_init: true)

    attr_reader :id, :concept_id, :title, :description, :publication_date, :files

    def initialize(json)
      data = JSON.parse(json)
      @id = data['id'].to_s
      @concept_id = data['conceptrecid']
      @title = data.dig('metadata', 'title')
      @description = data.dig('metadata', 'description')
      @publication_date = data.dig('metadata', 'publication_date')
      @files = Array(data['files']).map do |f|
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
    end

    private

    def encode_url_path(url)
      Addressable::URI.parse(url).normalize.to_s
    rescue Addressable::URI::InvalidURIError => e
      raise "Invalid URL from Zenodo: #{url.inspect} (#{e.message})"
    end
  end
end
