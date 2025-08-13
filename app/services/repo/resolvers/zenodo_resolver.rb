# frozen_string_literal: true

module Repo
  module Resolvers
    class ZenodoResolver < Repo::BaseResolver
      include LoggingCommon

      ZENODO_INFO_ENDPOINT = '/api/records'

      def self.build
        new
      end

      def priority
        9_000
      end

      def resolve(context)
        return unless context.object_url
        return if context.type

        repo_url = Zenodo::ZenodoUrl.parse(context.object_url)

        domain = repo_url.domain
        return unless domain
        repo_base_url = repo_url.zenodo_url

        log_info('Checking Zenodo API', { zenodo_url: repo_url.zenodo_url })
        responds = responds_to_api?(context.http_client, repo_url)
        if responds
          success(context, repo_base_url)
        end
      end

      private

      def responds_to_api?(http_client, repo_url)
        api_url = URI::Generic.build(
          scheme: repo_url.scheme,
          host: repo_url.domain,
          port: repo_url.port,
          path: ZENODO_INFO_ENDPOINT,
          query: 'page=1&size=1'
        )

        response = http_client.get(api_url.to_s)
        unless response.success?
          log_info('Not responding to Zenodo API', { api_url: api_url.to_s, response: response.status })
          return false
        end

        json = response.json
        # Zenodo's /api/records always returns a "hits" hash with "hits" key inside
        json.is_a?(Hash) && json['hits'].is_a?(Hash) && json['hits'].key?('hits')
      rescue => e
        log_error('Error while trying Zenodo API', { api_url: api_url }, e)
        false
      end

      def success(context, repo_base_url)
        context.type = ConnectorType::ZENODO
        context.repo_db.set(repo_base_url, type: ConnectorType::ZENODO)
      end
    end
  end
end
