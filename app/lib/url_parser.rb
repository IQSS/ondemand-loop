# frozen_string_literal: true

class UrlParser
  attr_reader :scheme, :domain, :port, :path, :params

  def self.parse(url)
    return nil if url.blank?

    uri = URI.parse(url)
    return nil unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    new(url)
  rescue URI::InvalidURIError
    nil
  end

  private_class_method :new

  def https?
    scheme == 'https'
  end

  def path_segments
    @path_segments ||= @path.split('/').reject(&:empty?)
  end

  def server_url
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
    @path = normalize_path(uri.path)
    @params = parse_query(uri.query)
  end

  def normalize_path(path)
    segments = path.split('/').reject(&:empty?)
    return '/' if segments.empty?

    '/' + segments.join('/')
  end

  def default_port(scheme)
    scheme == 'https' ? 443 : 80
  end

  def parse_query(query)
    return {} unless query

    URI.decode_www_form(query).to_h.symbolize_keys
  end
end
