module Doi
  # Doi::Resolvers::DataverseResolver
  #
  # This resolver attempts to determine whether a DOI corresponds to a Dataverse installation.
  # It first checks the DataCite metadata or redirect domain to identify the host. It then
  # verifies the domain by consulting the official Dataverse hub API for known installations.
  # If the domain is not listed, it performs a direct request to the Dataverse API endpoint
  # on the suspected domain to check for a valid response.
  #
  # Methods:
  # - `resolve`: Uses the domain information and Dataverse verification logic to determine
  #   if the DOI belongs to a Dataverse instance.
  # - `priority`: Returns the priority of this resolver to control its order in the
  #   resolution process.
  module Resolvers
    class DataverseResolver < Doi::BaseResolver
      include LoggingCommon

      DATAVERSE_INFO_ENDPOINT = '/api/info/version'

      def self.build
        new(dataverse_hub_registry: DataverseHubRegistry.registry)
      end

      def initialize(dataverse_hub_registry:)
        @dataverse_hub_registry = dataverse_hub_registry
      end

      def priority
        10_000
      end

      def resolve(context)
        return unless context.object_url

        domain = URI(context.object_url).host
        return unless domain

        log_info('Checking DataverseHub', {domain: domain})
        if known_dataverse_installation?(domain)
          context.type = 'dataverse'
          return
        end

        log_info('Checking Dataverse API', {domain: domain})
        if responds_to_api?(context.http_client, domain)
          context.type = 'dataverse'
          return
        end
      end

      private

      def known_dataverse_installation?(domain)
        @dataverse_hub_registry.installations.any? do |installation|
          installation[:hostname] == domain
        end
      end

      def responds_to_api?(http_client, domain)
        api_url = URI::HTTPS.build(host: domain, path: DATAVERSE_INFO_ENDPOINT)
        response =  http_client.get(api_url.to_s)
        return false unless response.success?

        json = response.json
        json['data'] && json['data']['version']
      rescue => e
        log_error('Error while trying Dataverse API', {api_url: api_url}, e)
        false
      end

    end
  end
end
