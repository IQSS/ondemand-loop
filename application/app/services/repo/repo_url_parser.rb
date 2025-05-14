# frozen_string_literal: true

module Repo
  class RepoUrlParser
    attr_reader :scheme, :domain, :port, :type, :doi, :code, :version

    def self.parse(url)
      uri = URI.parse(url)
      return nil unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      new(url)
    rescue URI::InvalidURIError
      nil
    end

    private_class_method :new

    def repo_url
      URI::Generic.build(
        scheme: scheme,
        host: domain,
        port: port
      ).to_s
    end

    private

    def initialize(url)
      @url = url
      parse_url
    end

    def parse_url
      uri = URI.parse(@url)
      @scheme = uri.scheme
      @domain = uri.host
      @port = uri.port if uri.port && uri.port != default_port(uri.scheme)

      @type = extract_type(uri.path)
      query_params = parse_query(uri.query)
      @doi = query_params['persistentId']
      @version = query_params['version']
      @code = extract_code(uri.path)
    end

    def default_port(scheme)
      scheme == 'https' ? 443 : 80
    end

    def extract_type(path)
      case path
      when /dataset\.xhtml/
        'dataset'
      when /file\.xhtml/
        'file'
      when %r{^/dataverse/}
        'collection'
      else
        'unknown'
      end
    end

    def parse_query(query)
      return {} unless query
      URI.decode_www_form(query).to_h
    end

    def extract_code(path)
      return nil unless path
      match = path.match(%r{^/dataverse/([^/?#]+)})
      match[1] if match
    end
  end
end
