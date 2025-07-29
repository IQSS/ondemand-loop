# frozen_string_literal: true

module Dataverse
  class DataverseUrl
    include Dataverse::Concerns::DataverseUrlBuilder

    TYPES = %w[dataverse collection dataset file unknown].freeze

    VERSION_MAP = {
      'draft' => ':draft',
      'latest' => ':latest',
      'latest-published' => ':latest-published'
    }.freeze

    attr_reader :type, :collection_id, :dataset_id, :file_id, :version

    def self.parse(url)
      base = UrlParser.parse(url)
      return nil unless base

      new(base)
    end

    def self.collection_from_parts(domain, collection_id, scheme: 'https', port: nil)
      raise 'domain is missing' unless domain
      raise 'collection_id is missing' unless collection_id

      dataverse_url = Dataverse::Concerns::DataverseUrlBuilder.build_dataverse_url(scheme, domain, port)
      collection_url = Dataverse::Concerns::DataverseUrlBuilder.build_collection_url(dataverse_url, collection_id)
      self.parse(collection_url)
    end

    def self.dataset_from_parts(domain, dataset_id, version: nil, scheme: 'https', port: nil)
      raise 'domain is missing' unless domain

      dataverse_url = Dataverse::Concerns::DataverseUrlBuilder.build_dataverse_url(scheme, domain, port)
      dataset_url = Dataverse::Concerns::DataverseUrlBuilder.build_dataset_url(dataverse_url, dataset_id, version: version)
      self.parse(dataset_url)
    end

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end

    private_class_method :new
    def initialize(base_parser)
      @base = base_parser
      parse_type_and_ids
    end

    def scheme_override
      'http' unless @base.https?
    end

    def scheme
      @base.scheme
    end

    def domain
      @base.domain
    end

    def port
      @base.port
    end

    def dataverse_url
      build_dataverse_url(@base.scheme, @base.domain, @base.port)
    end

    private

    def parse_type_and_ids
      segments = @base.path_segments

      if segments.length == 2 && segments[0] == 'dataverse'
        @type = 'collection'
        @collection_id = segments[1]
      elsif segments.length == 1 && %w[dataset.xhtml citation citation.xhtml].include?(segments[0]) && @base.params[:persistentId]
        @type = 'dataset'
        @dataset_id = @base.params[:persistentId]
        @version = map_version(@base.params[:version])
      elsif segments == ['file.xhtml']
        @type = 'file'
        @dataset_id = @base.params[:persistentId]
        @file_id = @base.params[:fileId] || extract_file_id(@dataset_id)
        @version = map_version(@base.params[:version])
      elsif segments.empty?
        @type = 'dataverse'
      else
        @type = 'unknown'
      end
    end

    def map_version(version_str)
      return nil unless version_str
      return version_str if version_str.start_with?(':')

      VERSION_MAP.fetch(version_str.downcase, version_str)
    end

    def extract_file_id(persistent_id)
      return nil unless persistent_id

      parts = persistent_id.split('/')
      parts.length > 1 ? parts.last : nil
    end
  end
end
