module Repo
  module Resolvers
    class DataCiteResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new(api_url: 'https://api.datacite.org')
      end

      def initialize(api_url:)
        @api_url = api_url
      end

      def resolve(context)
        return unless context.doi

        api_url = File.join(@api_url, '/dois', context.doi)
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