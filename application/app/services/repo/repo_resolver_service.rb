module Repo
  class RepoResolverService
    include LoggingCommon

    def initialize(resolvers)
      @resolvers = resolvers
    end

    def resolve(object_url)
      return { type: nil } if object_url.blank?

      context = RepoResolverContext.new(object_url)

      @resolvers.each do |resolver|
        resolver.resolve(context)
        break if context.result.resolved?
      rescue => e
        log_error('Error while executing URL resolvers', {resolver: resolver.class.name}, e)
        break
      end

      context.result
    end
  end

end

