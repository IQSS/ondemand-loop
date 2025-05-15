module Repo
  module Resolvers
    class DataCiteResolver < Repo::BaseResolver
      include LoggingCommon

      DATACITE_DOMAIN = 'https://api.datacite.org'

      def self.build
        http = Common::HttpClient.new(base_url: DATACITE_DOMAIN)
        new(http_client: http)
      end

      def initialize(http_client:)
        @http = http_client
      end

      def resolve(context)
        return unless context.doi

        api_url = File.join(DATACITE_DOMAIN, '/dois', context.doi)
        response =  context.http_client.get(api_url.to_s, headers: { 'Accept' => 'application/json' })
        return unless response.success?

        context.datacite_response = response
        type = response.json.dig('data', 'attributes', 'types', 'resourceTypeGeneral')
        context.type = type if type
        log_info('DOI resolved', {doi: context.doi, response: response.json})
      rescue => e
        log_error('Error while using DataCite API', {url: api_url}, e)
      end
    end

  end
end