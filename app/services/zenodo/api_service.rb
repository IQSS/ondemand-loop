module Zenodo
  class ApiService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'Authorization'

    class UnauthorizedException < Exception; end
    class ApiKeyRequiredException < Exception; end
  end
end