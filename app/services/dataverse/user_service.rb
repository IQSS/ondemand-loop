module Dataverse
  class UserService < Dataverse::ApiService

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key: nil)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @api_key = api_key
    end

    def get_user_profile
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('users')
              .add_path(':me')
              .to_s
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting user profile: #{response.status} - #{response.body}" unless response.success?
      UserProfileResponse.new(response.body)
    end
  end
end