# frozen_string_literal: true

require 'resolv'

module Repo
  module Resolvers
    class DomainResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      # Highest priority so it runs before other resolvers
      def priority
        100_000
      end

      def resolve(context)
        return unless context.parsed_input.nil?

        input = context.input
        parsed = RepoUrl.parse("https://#{input}")
        domain = parsed&.domain

        log_info('Checking input', {input: input, domain: domain, candidate: parsed})
        return unless resolvable_domain?(domain)

        context.input = parsed.to_s
        log_info('Input verified as domain', {input: input, domain: domain, candidate: parsed})
      end

      private

      def resolvable_domain?(domain)
        return false if domain.blank?
        Resolv.getaddress(domain)
        true
      rescue Resolv::ResolvError
        false
      end
    end
  end
end
