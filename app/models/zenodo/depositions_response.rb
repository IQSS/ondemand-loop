# frozen_string_literal: true

require_relative 'deposition'

module Zenodo
  class DepositionsResponse
    include ActsAsPage
    attr_reader :items

    def initialize(json, page:, per_page:, total_count: nil)
      data = JSON.parse(json)
      @page = page
      @per_page = per_page
      @total_count = total_count || Array(data).size
      @items = Array(data).map { |item| Deposition.new(item) }
    end
  end
end
