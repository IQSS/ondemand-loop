module Zenodo
  class RecordService
    include LoggingCommon

    def initialize(zenodo_url = 'https://zenodo.org', http_client: Common::HttpClient.new(base_url: zenodo_url))
      @zenodo_url = zenodo_url
      @http_client = http_client
    end

    def find_record(record_id)
      url = FluentUrl.new('')
              .add_path('api')
              .add_path('records')
              .add_path(record_id)
              .to_s
      response = @http_client.get(url)
      return nil unless response.success?
      RecordResponse.new(response.body)
    end
  end
end
