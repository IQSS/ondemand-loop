# frozen_string_literal: true

module Zenodo
  class CreateDepositionResponse
    attr_reader :id, :doi, :metadata, :links, :raw

    def initialize(response_body)
      @raw = JSON.parse(response_body)
      @id = @raw['id']
      @doi = @raw.dig('metadata', 'doi')
      @metadata = @raw['metadata']
      @links = @raw['links'] || {}
    end

    def bucket_url
      @links['bucket']
    end

    def html_url
      @links['html']
    end

    def api_url
      @links['self']
    end

    def editable?
      @raw['submitted'] == false
    end
  end
end
