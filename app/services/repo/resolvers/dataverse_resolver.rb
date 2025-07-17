module Repo
  module Resolvers
    class DataverseResolver < Repo::BaseResolver
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

        repo_url = Dataverse::DataverseUrl.parse(context.object_url)

        domain = repo_url.domain
        return unless domain
        repo_base_url = repo_url.dataverse_url

        log_info('Checking RepoCache', {repo_url: repo_base_url})
        repo_info = context.repo_db.get(repo_base_url)
        if repo_info
          context.type = repo_info.type
          return
        end

        log_info('Checking DataverseHub', {domain: domain})
        if known_dataverse_installation?(domain)
          success(context, repo_base_url)
          return
        end

        log_info('Checking Dataverse API', {dataverse_url: repo_url.dataverse_url})
        if responds_to_api?(context.http_client, repo_url)
          success(context, repo_base_url)
          return
        end
      end

      private

      def known_dataverse_installation?(domain)
        @dataverse_hub_registry.installations.any? do |installation|
          installation[:hostname] == domain
        end
      end

      def responds_to_api?(http_client, repo_url)
        api_url = URI::Generic.build(
          scheme: repo_url.scheme,
          host: repo_url.domain,
          port: repo_url.port,
          path: DATAVERSE_INFO_ENDPOINT
        )
        response =  http_client.get(api_url.to_s)
        return false unless response.success?

        json = response.json
        json['data'] && json['data']['version']
      rescue => e
        log_error('Error while trying Dataverse API', {api_url: api_url}, e)
        false
      end

      def success(context, repo_base_url)
        context.type = ConnectorType::DATAVERSE
        context.repo_db.set(repo_base_url, type: ConnectorType::DATAVERSE)
      end

    end
  end
end
