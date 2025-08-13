# frozen_string_literal: true

module Repo
  module Resolvers
    class ZenodoDoiResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      # Run after ZenodoResolver
      def priority
        8_000
      end

      def resolve(context)
        return unless context.object_url
        return unless context.type&.zenodo?

        zenodo_url = Zenodo::ZenodoUrl.parse(context.object_url)
        return unless zenodo_url&.doi?

        response = context.http_client.head(context.object_url)
        if response.redirect?
          new_url = response.location
          log_info('Zenodo DOI resolved', { doi_url: context.object_url, object_url: new_url })
          context.object_url = new_url
        else
          log_info('Unable to resolve Zenodo DOI', { doi_url: context.object_url, response: response.status })
        end
      end
    end
  end
end
