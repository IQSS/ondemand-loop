# frozen_string_literal: true

module Zenodo
  class CreateDepositionRequest
    attr_reader :title, :upload_type, :description, :creators, :keywords, :publication_date, :access_right

    def initialize(title:, upload_type:, description:, creators:, keywords: nil, publication_date: nil, access_right: 'open')
      @title = title
      @upload_type = upload_type
      @description = description
      @creators = creators
      @keywords = keywords
      @publication_date = publication_date
      @access_right = access_right
    end

    def to_h
      {
        title: @title,
        upload_type: @upload_type,
        description: @description,
        creators: @creators,
        keywords: @keywords,
        publication_date: @publication_date,
        access_right: @access_right
      }.compact
    end
  end
end
