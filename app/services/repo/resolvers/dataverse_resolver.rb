module Repo
  module Resolvers
    class DataverseResolver < Repo::BaseResolver
      include LoggingCommon

      DATAVERSE_INFO_ENDPOINT = '/api/info/version'

      def self.build
        new
      end

      def priority
        10_000
      end

      def resolve(context)
        return unless context.object_url
        return if context.type

        repo_url = Dataverse::DataverseUrl.parse(context.object_url)

        domain = repo_url.domain
        return unless domain
        repo_base_url = repo_url.dataverse_url

        log_info('Checking Dataverse API', {dataverse_url: repo_url.dataverse_url})
        version = responds_to_api?(context.http_client, repo_url)
        if version
          success(context, repo_base_url, api_version: version)
          return
        end
      end

      private


      def responds_to_api?(http_client, repo_url)
        api_url = URI::Generic.build(
          scheme: repo_url.scheme,
          host: repo_url.domain,
          port: repo_url.port,
          path: DATAVERSE_INFO_ENDPOINT
        )
        response = http_client.get(api_url.to_s)
        unless response.success?
          log_info('Not responding to Dataverse API', {api_url: api_url.to_s, response: response.status})
          return nil
        end
        return nil unless response.success?

        json = response.json
        json['data'] && json['data']['version']
      rescue => e
        log_error('Error while trying Dataverse API', {api_url: api_url}, e)
        nil
      end

      def success(context, repo_base_url, api_version: nil)
        context.type = ConnectorType::DATAVERSE
        context.repo_db.set(
          repo_base_url,
          type: ConnectorType::DATAVERSE,
          metadata: { api_version: api_version }
        )
      end

    end
  end
end
