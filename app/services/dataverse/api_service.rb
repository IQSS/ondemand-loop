module Dataverse
  class ApiService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'X-Dataverse-key'
    class UnauthorizedException < StandardError; end
    class ApiKeyRequiredException < StandardError; end
  end
end