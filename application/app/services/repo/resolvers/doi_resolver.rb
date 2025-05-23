# frozen_string_literal: true
module Repo
  module Resolvers
    class DoiResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new(api_url: 'https://doi.org')
      end

      def initialize(api_url:)
        @api_url = api_url
      end

      def priority
        99_000
      end

      def resolve(context)
        if context.parsed_input.nil?
          context.doi = context.input
          doi_url = URI.parse(File.join(@api_url, context.input)).to_s
        else
          doi_url = context.parsed_input.repo_url
        end

        object_url = doi_url.include?(@api_url) ? check_url(context, doi_url) : context.input
        context.object_url = object_url
      end

      private

      def check_url(context, doi_url)
        response = context.http_client.head(doi_url)
        if response.redirect?
          object_url = response.location
          log_info('DOI resolved', {doi_url: doi_url, object_url: object_url})
          object_url
        else
          log_info('Unable to resolve DOI', {doi_url: doi_url, response: response.status})
          nil
        end
      end

    end
  end
end
