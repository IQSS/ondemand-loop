module Repo
  class RepoResolverService
    include LoggingCommon

    def self.build
      resolvers = []
      Repo::Resolvers.constants.each do |constant_name|
        constant = Repo::Resolvers.const_get(constant_name)
        if constant.is_a?(Class) && constant < Repo::BaseResolver
          resolvers << constant.build
        end
      end
      resolvers.sort_by! { |r| -r.priority }
      LoggingCommon.log_info("[RepoResolverService] Resolvers loaded: #{resolvers.map { |r| "#{r.class} (#{r.priority})" }.join(', ')}")
      new(resolvers)
    end

    def initialize(resolvers)
      @resolvers = resolvers
    end

    def resolve(object_url)
      context = RepoResolverContext.new(object_url)
      return context.result if object_url.blank?

      @resolvers.each do |resolver|
        resolver.resolve(context)
      rescue => e
        log_error('Error while executing URL resolvers', {resolver: resolver.class.name}, e)
        break
      end

      result = context.result
      log_info('Resolution completed', { input: context.input, object_url: result.object_url, type: result.type })
      result
    end
  end

end

