# frozen_string_literal: true

module Zenodo
  class ZenodoUrl
    DEFAULT_SERVER = 'zenodo.org'
    DEFAULT_URL = 'https://zenodo.org'
    TYPES = %w[zenodo doi record deposition file unknown].freeze

    attr_reader :type, :record_id, :deposition_id, :file_name
    delegate :domain, :scheme, :scheme_override, :port, :port_override, to: :base

    def self.parse(url)
      base = Repo::RepoUrl.parse(url)
      return nil unless base

      new(base)
    end

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end

    private_class_method :new
    def initialize(base_parser)
      @base = base_parser
      parse_type_and_ids
    end

    def zenodo_url
      base = "#{@base.scheme}://#{@base.domain}"
      base += ":#{@base.port}" if @base.port
      FluentUrl.new(base).to_s
    end

    private

    def base
      @base
    end

    def record_segment?(seg)
      seg == 'record' || seg == 'records'
    end

    def parse_type_and_ids
      segments = @base.path_segments

      if segments.length > 1 && segments[0] == 'doi'
        @type = 'doi'
      elsif segments.length == 2 && record_segment?(segments[0])
        @type = 'record'
        @record_id = segments[1]
      elsif segments.length >= 4 && record_segment?(segments[0]) && segments[2] == 'files'
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
