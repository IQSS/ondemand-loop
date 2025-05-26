# RepoRegistry
#
# This module manages the loading, sorting, and registration of Repo resolvers.
# It dynamically loads resolver classes from the `Repo::Resolvers` module, instantiates them
# using their `build` class method, and sorts them by their `priority` method in descending order.
# The sorted resolvers are then made available for resolving Repo URLs.
#
# This module manages the repo cache used to avoid having to resolve the same domain multiple times.
#
module RepoRegistry
  mattr_accessor :resolvers
  mattr_accessor :repo_db

  # Method to find all resolvers within the Doi::Resolvers module
  def self.build_resolvers
    resolvers = []

    # Iterate over all constants within the Doi::Resolvers module
    Repo::Resolvers.constants.each do |constant_name|
      constant = Repo::Resolvers.const_get(constant_name)

      # Check if it's a class and a subclass of BaseResolver
      if constant.is_a?(Class) && constant < Repo::BaseResolver
        resolvers << constant.build # Build the resolver
      end
    end
    resolvers.sort_by{ |r| -r.priority } # Sort by priority descendant
  end

  def self.build_repo_db
    Repo::RepoDb.new(db_path: ::Configuration.repo_db_file)
  end
end

Rails.application.config.to_prepare do
  RepoRegistry.resolvers = RepoRegistry.build_resolvers
  RepoRegistry.repo_db = RepoRegistry.build_repo_db

  Rails.logger.info "[RepoRegistry] Resolvers loaded: #{RepoRegistry.resolvers.map { |r| "#{r.class} (#{r.priority})" }.join(', ')}"
  Rails.logger.info "[RepoRegistry] RepoDb created entries: #{RepoRegistry.repo_db.size} path: #{RepoRegistry.repo_db.db_path}"
end