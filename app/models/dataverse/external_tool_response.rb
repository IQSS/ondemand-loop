module Dataverse
  class ExternalToolResponse
    attr_accessor :status, :data

    def initialize(json_str)
      parsed_data = JSON.parse(json_str)
      @status = parsed_data["status"]
      @data = Data.new(parsed_data["data"])
    end

    class Data
      attr_accessor :query_parameters, :signed_urls

      def initialize(data)
        @query_parameters = QueryParameters.new(data["queryParameters"])
        @signed_urls = data["signedUrls"].map { |url| SignedUrl.new(url) }
      end

      class QueryParameters
        attr_accessor :dataset_pid, :dataset_id

        def initialize(data)
          @dataset_pid = data["datasetPid"]
          @dataset_id = data["datasetId"]
        end
      end

      class SignedUrl
        attr_accessor :name, :http_method, :signed_url, :time_out

        def initialize(data)
          @name = data["name"]
          @http_method = data["httpMethod"]
          @signed_url = data["signedUrl"]
          @time_out = data["timeOut"]
        end
      end
    end
  end
end