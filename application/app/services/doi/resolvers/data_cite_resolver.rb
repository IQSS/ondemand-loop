module Doi
  module Resolvers
    # Doi::Resolvers::DataCiteResolver
    #
    # This resolver uses the DataCite API to fetch metadata about a given DOI. It queries
    # the DataCite service to retrieve detailed information about the DOI, which helps
    # determine the type of the object associated with the DOI. This resolver is typically
    # used when other resolvers cannot resolve the DOI or when additional metadata is needed
    # to identify the DOI's type.
    #
    # Methods:
    # - `resolve`: Queries the DataCite API to fetch metadata for the DOI and uses that
    #   metadata to resolve the DOI's type.
    # - `priority`: Returns the priority of this resolver to control its position in the
    #   resolution process.
    class DataCiteResolver < Doi::BaseResolver
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
        return if context.datacite_response # cached

        response = @http.get("/dois/#{context.doi}", headers: { 'Accept' => 'application/json' })
        return unless response.success?

        context.datacite_response = response
        type = response.json.dig('data', 'attributes', 'types', 'resourceTypeGeneral')
        context.type = type if type
      rescue => e
        log_error('Error while using DataCite API', {domain: DATACITE_DOMAIN}, e)
      end
    end

  end
end