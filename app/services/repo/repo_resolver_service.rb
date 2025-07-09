module Repo
  class RepoResolverService
    include LoggingCommon

    def initialize(resolvers)
      @resolvers = resolvers
    end

    def resolve(object_url)
      context = RepoResolverContext.new(object_url)
      return context.result if object_url.blank?

      @resolvers.each do |resolver|
        resolver.resolve(context)
        break if context.result.resolved?
      rescue => e
        log_error('Error while executing URL resolvers', {resolver: resolver.class.name}, e)
        break
      end

      result = context.result
      log_info('Resolution completed', { object_url: result.object_url, type: result.type })
      result
    end
  end

end

