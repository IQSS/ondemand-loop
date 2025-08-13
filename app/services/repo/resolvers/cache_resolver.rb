module Repo
  module Resolvers
    class CacheResolver < Repo::BaseResolver
      include LoggingCommon

      def self.build
        new
      end

      def priority
        90_000
      end

      def resolve(context)
        return unless context.object_url

        repo_url = Repo::RepoUrl.parse(context.object_url)
        return unless repo_url

        repo_base_url = repo_url.server_url

        log_info('Checking RepoCache', { repo_url: repo_base_url })
        repo_info = context.repo_db.get(repo_base_url)
        if repo_info
          log_info('RepoCache hit', { repo_url: repo_base_url, type: repo_info.type })
          context.type = repo_info.type
        end
      end
    end
  end
end
