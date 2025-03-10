module Dataverse
  class DataverseService
    def process_callback(callback)
      decoded = Base64.decode64(callback)
      parsed_url = URI.parse(decoded)
      parsed_url.host = "host.docker.internal" if ENV["container"]

      response = Net::HTTP.get_response(parsed_url)

      if response.is_a?(Net::HTTPSuccess)
        payload = response.body
      else
        payload = nil
      end

      payload ? ExternalToolResponse.new(payload) : nil
    end

    def dataset_details(dataverse_host, dataset_id)

    end
  end
end