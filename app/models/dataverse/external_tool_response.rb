module Dataverse
  class ExternalToolResponse
    attr_accessor :status, :data

    def initialize(json_str)
      parsed_data = JSON.parse(json_str)
      @status = parsed_data["status"]
      @data = ExternalToolData.new(parsed_data["data"])
    end
  end

  class ExternalToolData
    attr_accessor :query_parameters, :signed_urls

    def initialize(data)
      @query_parameters = ExternalToolQueryParameters.new(data["queryParameters"])
      @signed_urls = data["signedUrls"].map { |url| ExternalToolSignedUrl.new(url) }
    end
  end

  class ExternalToolQueryParameters
    attr_accessor :dataset_pid, :dataset_id

    def initialize(data)
      @dataset_pid = data["datasetPid"]
      @dataset_id = data["datasetId"]
    end
  end

  class ExternalToolSignedUrl
    attr_accessor :name, :http_method, :signed_url, :time_out

    def initialize(data)
      @name = data["name"]
      @http_method = data["httpMethod"]
      @signed_url = data["signedUrl"]
      @time_out = data["timeOut"]
    end
  end
end