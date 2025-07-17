# frozen_string_literal: true

module Repo
  module Resolvers
    class ZenodoResolver < Repo::BaseResolver
      include LoggingCommon

      ZENODO_DOMAINS = ['zenodo.org', 'sandbox.zenodo.org'].freeze

      def self.build
        new
      end

      def priority
        9000
      end

      def resolve(context)
        return unless context.object_url

        repo_url = Zenodo::ZenodoUrl.parse(context.object_url)
        return unless repo_url
        return unless ZENODO_DOMAINS.include?(repo_url.domain)

        context.type = ConnectorType::ZENODO
        context.repo_db.set(repo_url.zenodo_url, type: ConnectorType::ZENODO)

        log_info("ZenodoResolver matched URL: #{context.object_url}")
      end
    end
  end
end
