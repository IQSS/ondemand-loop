# frozen_string_literal: true

module Zenodo
  class UserService < Zenodo::ApiService
    def initialize(zenodo_url, http_client: Common::HttpClient.new(base_url: zenodo_url), api_key:)
      @zenodo_url = zenodo_url
      @http_client = http_client
      @api_key = api_key
    end

    def list_depositions(page: 1, per_page: 20)
      raise ApiKeyRequiredException unless @api_key

      headers = {
        'Content-Type' => 'application/json',
        AUTH_HEADER => "Bearer #{@api_key}"
      }

      url = "/api/deposit/depositions?page=#{page}&size=#{per_page}"
      response = @http_client.get(url, headers: headers)

      return [] if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error retrieving depositions: #{response.status} - #{response.body}" unless response.success?

      JSON.parse(response.body)
    end

    def list_user_records(q: nil, page: 1, per_page: 20, all_versions: false)
      raise ApiKeyRequiredException unless @api_key

      headers = {
        'Content-Type' => 'application/json',
        AUTH_HEADER => "Bearer #{@api_key}"
      }

      query = q ? "q=#{CGI.escape(q)}&" : ''
      url = "/api/records?#{query}all_versions=#{all_versions}&page=#{page}&size=#{per_page}"
      response = @http_client.get(url, headers: headers)

      return [] if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error retrieving records: #{response.status} - #{response.body}" unless response.success?

      JSON.parse(response.body)
    end

    def get_user_profile
      raise ApiKeyRequiredException unless @api_key

      headers = {
        'Content-Type' => 'application/json',
        AUTH_HEADER => "Bearer #{@api_key}"
      }

      url = '/api/me'
      response = @http_client.get(url, headers: headers)

      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error retrieving user profile: #{response.status} - #{response.body}" unless response.success?

      body = JSON.parse(response.body)
      {
        fullname: body['fullname'],
        email: body['email']
      }
    end
  end
end
