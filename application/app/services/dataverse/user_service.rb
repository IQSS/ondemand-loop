module Dataverse
  class UserService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'X-Dataverse-key'
    class UnauthorizedException < Exception; end
    class ApiKeyRequiredException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), api_key: nil)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @file_utils = file_utils
      @api_key = api_key
    end

    def get_user_profile
      raise ApiKeyRequiredException unless @api_key

      headers = { 'Content-Type' => 'application/json', AUTH_HEADER => @api_key }
      url = "/api/users/:me"
      response = @http_client.get(url, headers: headers)
      return nil if response.not_found?
      raise UnauthorizedException if response.unauthorized?
      raise "Error getting user profile: #{response.status} - #{response.body}" unless response.success?
      UserProfileResponse.new(response.body)
    end
  end
end