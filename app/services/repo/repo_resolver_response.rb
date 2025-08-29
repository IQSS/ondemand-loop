# frozen_string_literal: true

module Repo
  class RepoResolverResponse
    attr_reader :object_url, :type
    def initialize(object_url, type)
      @object_url = object_url
      @type = type
    end

    def resolved?
      object_url.present? && type.present?
    end

    def unknown?
      type.nil?
    end
  end
end