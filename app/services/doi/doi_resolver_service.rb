module Doi
  # Doi::DoiResolverService
  #
  # This class is responsible for processing the resolution of a DOI. It loops through
  # the available resolvers in the registry and attempts to resolve the DOI using each
  # resolver until one successfully resolves it. The class orchestrates the resolution
  # process, providing the context and managing the flow of resolvers.
  #
  # Methods:
  # - `resolve`: Iterates through all registered resolvers, passing the DOI and context,
  #   and invokes the first resolver that successfully resolves the DOI.
  class DoiResolverService
    def initialize(resolvers)
      @resolvers = resolvers
    end

    def resolve(doi, object_url)
      context = DoiResolverContext.new(doi, object_url)

      @resolvers.each do |resolver|
        resolver.resolve(context)
        break if context.result
      end

      context.result || { type: "Unknown" }
    end
  end
end

