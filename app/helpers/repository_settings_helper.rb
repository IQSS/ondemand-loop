module RepositorySettingsHelper
  def browse_repository_path(repo_url, entry)
    resolver = ConnectorClassDispatcher.repo_controller_resolver(entry.type)
    resolver.get_controller_url(repo_url).redirect_url
  end
end
