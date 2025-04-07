module Dataverse
  class ExternalToolService
    def process_callback(callback)
      decoded = Base64.decode64(callback)
      parsed_url = URI.parse(decoded)
      #TODO: We need to remove this at some point
      parsed_url.host = "host.docker.internal" if ENV["container"]

      response = Net::HTTP.get_response(parsed_url)
      external_tool_response = response.is_a?(Net::HTTPSuccess) ? ExternalToolResponse.new(response.body) : nil

      dataverse_url = URI::Generic.build(scheme: parsed_url.scheme, host: parsed_url.hostname, port: parsed_url.port)

      {
        response: external_tool_response,
        dataverse_uri: dataverse_url,
      }
    end
  end
end