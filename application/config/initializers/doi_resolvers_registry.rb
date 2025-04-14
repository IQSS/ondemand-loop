# DoiResolversRegistry
#
# This module manages the loading, sorting, and registration of DOI resolvers.
# It dynamically loads resolver classes from the `Doi::Resolvers` module, instantiates them
# using their `build` class method, and sorts them by their `priority` method in descending order.
# The sorted resolvers are then made available for resolving DOIs.
#
# Methods:
# - `build_resolvers`: Loads and sorts resolvers by priority.
# - `resolvers`: Returns the list of resolvers, sorted by priority.
module DoiResolversRegistry
  mattr_accessor :resolvers

  # Method to find all resolvers within the Doi::Resolvers module
  def self.build_resolvers
    resolvers = []

    # Iterate over all constants within the Doi::Resolvers module
    Doi::Resolvers.constants.each do |constant_name|
      constant = Doi::Resolvers.const_get(constant_name)

      # Check if it's a class and a subclass of BaseResolver
      if constant.is_a?(Class) && constant < Doi::BaseResolver
        resolvers << constant.build # Build the resolver
      end
    end
    resolvers.sort_by{ |r| -r.priority } # Sort by priority descendant
  end
end

Rails.application.config.to_prepare do
  DoiResolversRegistry.resolvers = DoiResolversRegistry.build_resolvers

  Rails.logger.info "[DoiResolverRegistry] Loaded: #{DoiResolversRegistry.resolvers.map { |r| "#{r.class} (#{r.priority})" }.join(', ')}"
end