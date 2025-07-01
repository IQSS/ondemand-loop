require 'addressable'

module Zenodo
  class SearchResponse
    include ActsAsPage
    attr_reader :items

    FileItem = Zenodo::RecordResponse::FileItem

    def initialize(json, page, per_page)
      data = JSON.parse(json)
      @page = page
      @per_page = per_page
      hits = data.fetch('hits', {})
      total = hits['total']
      @total_count = if total.is_a?(Hash)
                       total['value']
                     else
                       total || Array(hits['hits']).count
                     end
      @items = Array(hits['hits']).map do |hit|
        OpenStruct.new(
          id: hit['id'].to_s,
          title: hit.dig('metadata', 'title'),
          description: hit.dig('metadata', 'description'),
          publication_date: hit.dig('metadata', 'publication_date'),
          files: parse_files(hit['files'])
        )
      end
    end

    private

    def parse_files(files)
      Array(files).map do |f|
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

    def encode_url_path(url)
      Addressable::URI.parse(url).normalize.to_s
    rescue Addressable::URI::InvalidURIError => e
      raise "Invalid URL from Zenodo: #{url.inspect} (#{e.message})"
    end
  end
end
