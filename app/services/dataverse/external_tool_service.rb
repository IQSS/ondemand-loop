module Dataverse
  class ExternalToolService
    def process_callback(callback)
      decoded = Base64.decode64(callback)
      parsed_url = URI.parse(decoded)
      parsed_url.host = "host.docker.internal" if ENV["container"]

      dataverse_metadata = DataverseMetadata.find_or_initialize_by_uri(parsed_url)

      response = Net::HTTP.get_response(parsed_url)
      external_tool_response = response.is_a?(Net::HTTPSuccess) ? ExternalToolResponse.new(response.body) : nil

      {
        response: external_tool_response,
        metadata: dataverse_metadata,
      }
    end
  end
end