module Repo
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