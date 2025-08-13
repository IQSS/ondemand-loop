# frozen_string_literal: true

module Repo
  class RepoResolverContext
    attr_reader :input, :parsed_input, :http_client, :repo_db
    attr_accessor :object_url, :type

    def initialize(input, http_client: Common::HttpClient.new, repo_db: RepoRegistry.repo_db)
      @input = input
      @parsed_input = RepoUrl.parse(input)
      @http_client = http_client
      @repo_db = repo_db
    end

    def input=(value)
      @input = value
      @parsed_input = RepoUrl.parse(value)
    end

    def result
      RepoResolverResponse.new(object_url, type)
    end
  end

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

