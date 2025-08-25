# frozen_string_literal: true

module Zenodo
  class DepositionResponse
    attr_reader :deposition

    delegate :id, :record_id, :title, :description, :publication_date,
             :files, :file_count, :bucket_url, :submitted,
             :raw, :draft?, :version, :to_s, to: :deposition

    def initialize(response_body)
      @deposition = Deposition.new(JSON.parse(response_body))
    end
  end
end
