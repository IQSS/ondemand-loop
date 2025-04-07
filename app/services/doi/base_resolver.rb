module Doi
  # Doi::BaseResolver
  #
  # Base class for all DOI resolvers. It defines the common interface and behavior
  # that all resolver classes must implement. Each resolver subclass should implement
  # its own `resolve` method to handle the specific logic for resolving a DOI.
  # It also provides the `priority` method to determine the resolver's priority
  # when multiple resolvers are available. The `build` method is used by the resolver
  # registry to instantiate the resolver.
  #
  # Methods:
  # - `resolve`: Abstract method to be implemented by subclasses for resolving DOIs.
  # - `priority`: Returns the priority of the resolver to control the resolution order.
  # - `build`: Instantiates the resolver and returns an instance of it.
  class BaseResolver
    def self.build
      raise NotImplementedError, "#{name} must implement .build"
    end

    # Default priority
    def priority
      100
    end

    def resolve(context)
      raise NotImplementedError
    end
  end

end