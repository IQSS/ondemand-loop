require 'net/http'
require 'uri'
require 'json'

module Common
  # Common::HttpClient
  #
  # A generic HTTP client designed to simplify and abstract HTTP requests (GET, POST, HEAD).
  # This class provides an easy-to-use interface for making requests with support for custom
  # headers, query parameters, timeouts, and proxy configuration.
  #
  # The client allows for making synchronous HTTP requests and can automatically construct
  # the final URL by combining a base URL with a relative URL. It also handles the configuration
  # of timeout settings for connection and reading, as well as optional proxy support.
  #
  # Constructor:
  # - `initialize(base_url:, open_timeout: 5, read_timeout: 10, proxy: nil)`
  #   - `base_url`: The base URL to be used for all HTTP requests. This is an optional parameter.
  #   - `open_timeout`: The connection timeout in seconds (default is 5 seconds).
  #   - `read_timeout`: The read timeout in seconds (default is 10 seconds).
  #   - `proxy`: An optional hash with the proxy server settings:
  #       - `:host`: Proxy host (e.g., 'proxy.example.com')
  #       - `:port`: Proxy port (e.g., 8080)
  #       - `:user`: Proxy username (optional)
  #       - `:password`: Proxy password (optional)
  #
  # Methods:
  # - `get(path, params = {}, headers = {}, follow_redirects = false)`: Makes a GET request to the path adding the base_url if provided,
  #   optionally accepting request parameters and headers.
  # - `post(path, params = {}, body, headers = {})`: Makes a POST request to the provided path adding the base_url if provided,
  #   with the given request parameters, body payload and optional headers.
  # - `head(path, params = {}, headers = {})`: Makes a HEAD request to the path adding the base_url if provided,
  #   optionally accepting request parameters and headers.
  #
  # Example usage:
  #
  # # Creating the HttpClient with proxy settings
  # client = Common::HttpClient.new(
  #   base_url: 'https://api.example.com',
  #   open_timeout: 5,
  #   read_timeout: 10,
  #   proxy: { host: 'proxy.example.com', port: 8080, user: 'user', password: 'password' }
  # )
  #
  # # Making a GET request with parameters and headers using the client
  # params = { query: 'example', limit: 10 }
  # headers = { 'Authorization' => 'Bearer your_token' }
  # response = client.get('/path/to/resource', params, headers)
  #
  # # Making a POST request
  # body = { key: 'value' }
  # response = client.post('/path/to/resource', body, headers)
  #
  class HttpClient
    class Response
      attr_reader :status, :headers, :body, :raw

      def initialize(http_response)
        @raw = http_response
        @status = http_response.code.to_i
        @headers = http_response.each_header.to_h
        @body = http_response.body
      end

      def location
        headers['location']
      end

      def json
        JSON.parse(body)
      end

      def redirect?
        raw.is_a?(Net::HTTPRedirection)
      end

      def success?
        raw.is_a?(Net::HTTPSuccess)
      end

      def unauthorized?
        raw.is_a?(Net::HTTPUnauthorized)
      end

      def not_found?
        raw.is_a?(Net::HTTPNotFound)
      end
    end

    def initialize(base_url: nil, open_timeout: 5, read_timeout: 10, proxy: nil)
      @base_uri = base_url
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @proxy = proxy
    end

    def get(path, params: {}, headers: {}, follow_redirects: false)
      request(:get, path, headers: headers, params: params, follow_redirects: follow_redirects)
    end

    def post(path, params: {}, headers: {}, body: nil)
      request(:post, path, headers: headers, body: body, params: params)
    end

    def head(path, params: {}, headers: {})
      request(:head, path, headers: headers, params: params)
    end

    private

    def request(method, path, headers:, body: nil, params: {}, follow_redirects: false, limit: 5)
      raise "Too many redirects" if limit <= 0

      uri = URI.join(@base_uri.to_s, path.to_s)
      uri = add_query_params(uri, params) if params.any?

      http = build_http_client(uri)
      req = build_request(method, uri, headers, body)
      response = http.request(req)

      if follow_redirects && response.is_a?(Net::HTTPRedirection)
        location = URI.join(uri.to_s, response['location']).to_s
        return request(method, location, headers: headers, body: body, follow_redirects: true, limit: limit - 1)
      end

      Response.new(response)
    end

    def add_query_params(uri, params)
      existing = URI.decode_www_form(uri.query || "") + params.to_a
      uri.query = URI.encode_www_form(existing)
      uri
    end

    def build_http_client(uri)
      http = if @proxy
               Net::HTTP::Proxy(@proxy[:host], @proxy[:port], @proxy[:user], @proxy[:password]).new(uri.host, uri.port)
             else
               Net::HTTP.new(uri.host, uri.port)
             end

      http.use_ssl = uri.scheme == "https"
      # TODO remove this line after fixing container certificates to connect to hub.dataverse.org
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl? && uri.host == "hub.dataverse.org"
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout
      http
    end

    def build_request(method, uri, headers, body)
      klass = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        head: Net::HTTP::Head
      }[method] || raise(ArgumentError, "Unsupported method #{method}")

      request = klass.new(uri)
      headers.each { |k, v| request[k] = v }

      if body
        request.body = body.is_a?(String) ? body : body.to_json
        request['Content-Type'] ||= 'application/json'
      end

      request
    end
  end
end
