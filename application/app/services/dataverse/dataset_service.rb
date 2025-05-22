module Dataverse
  class DatasetService
    include LoggingCommon
    include DateTimeCommon

    class UnauthorizedException < Exception; end

    def initialize(dataverse_url, http_client: Common::HttpClient.new(base_url: dataverse_url), file_utils: Common::FileUtils.new)
      @dataverse_url = dataverse_url
      @http_client = http_client
      @file_utils = file_utils
    end
  end
end