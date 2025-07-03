# frozen_string_literal: true

module Zenodo
  class ZenodoUrl
    TYPES = %w[zenodo record deposition file unknown].freeze

    attr_reader :type, :record_id, :deposition_id, :file_name

    def self.parse(url)
      base = UrlParser.parse(url)
      return nil unless base

      new(base)
    end

    private_class_method :new

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
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

    def zenodo_url
      uri_class = @base.https? ? URI::HTTPS : URI::HTTP
      uri_class.build(host: @base.domain, port: @base.port).to_s
    end

    def initialize(base_parser)
      @base = base_parser
      parse_type_and_ids
    end

    private

    def parse_type_and_ids
      segments = @base.path_segments

      if segments.length == 2 && segments[0] == 'records'
        @type = 'record'
        @record_id = segments[1]
      elsif segments.length >= 4 && segments[0] == 'records' && segments[2] == 'files'
        @type = 'file'
        @record_id = segments[1]
        @file_name = segments[3..].join('/')
      elsif segments.length == 2 && segments[0] == 'uploads'
        @type = 'deposition'
        @deposition_id = segments[1]
      elsif segments.length == 2 && segments[0] == 'deposit'
        @type = 'deposition'
        @deposition_id = segments[1]
      elsif segments.empty?
        @type = 'zenodo'
      else
        @type = 'unknown'
      end
    end
  end
end
