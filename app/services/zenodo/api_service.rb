module Zenodo
  class ApiService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'Authorization'

    class UnauthorizedException < StandardError; end
    class ApiKeyRequiredException < StandardError; end
  end
end