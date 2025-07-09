# frozen_string_literal: true

module Dataverse
  class DataverseUrl
    include Dataverse::Concerns::DataverseUrlBuilder

    TYPES = %w[dataverse collection dataset file unknown].freeze

    attr_reader :type, :collection_id, :dataset_id, :file_id, :version

    def self.parse(url)
      base = UrlParser.parse(url)
      return nil unless base

      new(base)
    end

    private_class_method :new

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
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
      build_dataverse_url
    end

    def initialize(base_parser)
      @base = base_parser
      parse_type_and_ids
    end

    private

    def build_dataverse_url
      base = "#{@base.scheme}://#{@base.domain}"
      base += ":#{@base.port}" if @base.port
      FluentUrl.new(base).to_s
    end

    def parse_type_and_ids
      segments = @base.path_segments

      if segments.length == 2 && segments[0] == 'dataverse'
        @type = 'collection'
        @collection_id = segments[1]
      elsif segments.length == 1 && %w[dataset.xhtml citation citation.xhtml].include?(segments[0])
        @type = 'dataset'
        @dataset_id = @base.params[:persistentId]
        @version = @base.params[:version]
      elsif segments == ['file.xhtml']
        @type = 'file'
        @dataset_id = @base.params[:persistentId]
        @file_id = @base.params[:fileId] || extract_file_id(@dataset_id)
        @version = @base.params[:version]
      elsif segments.empty?
        @type = 'dataverse'
      else
        @type = 'unknown'
      end
    end

    def extract_file_id(persistent_id)
      return nil unless persistent_id

      parts = persistent_id.split('/')
      parts.length > 1 ? parts.last : nil
    end
  end
end
