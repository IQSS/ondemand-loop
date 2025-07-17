# frozen_string_literal: true

require 'addressable/uri'

class UrlParser
  attr_reader :scheme, :domain, :port, :path, :params

  def self.parse(url)
    return nil if url.blank?

    uri = Addressable::URI.parse(url)
    unless uri.scheme
      uri = Addressable::URI.parse("https://#{url}")
    end

    return nil unless uri.host

    new(uri)
  rescue Addressable::URI::InvalidURIError
    nil
  end

  private_class_method :new

  def https?
    scheme == 'https'
  end

  def path_segments
    @path_segments ||= path.split('/').reject(&:empty?)
  end

  def server_url
    Addressable::URI.new(
      scheme: scheme,
      host: domain,
      port: port
    ).to_s
  end

  private

  def initialize(uri)
    @scheme = uri.scheme
    @domain = uri.host
    @port = uri.port if uri.port && uri.port != default_port(uri.scheme)
    @path = normalize_path(uri.path)
    @params = parse_query(uri.query_values)
  end

  def normalize_path(raw_path)
    return '/' if raw_path.blank?

    segments = raw_path.split('/').reject(&:empty?)
    '/' + segments.join('/')
  end

  def default_port(scheme)
    scheme == 'https' ? 443 : 80
  end

  def parse_query(query_values)
    return {} unless query_values

    query_values.transform_keys(&:to_sym)
  end
end
