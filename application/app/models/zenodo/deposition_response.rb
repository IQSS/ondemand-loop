# frozen_string_literal: true

module Zenodo
  class DepositionResponse
    attr_reader :id, :title, :file_count, :bucket_url, :submitted, :raw

    def initialize(response_body)
      @raw = JSON.parse(response_body)

      @id = @raw['id']
      @submitted = @raw['submitted']
      @bucket_url = @raw.dig('links', 'bucket')
      @title = @raw.dig('metadata', 'title') || 'Untitled'
      @file_count = @raw['files']&.count || 0
    end

    def draft?
      submitted == false
    end
  end
end
