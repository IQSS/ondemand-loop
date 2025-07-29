module RepositorySettingsHelper
  def browse_repository_path(repo_url, entry)
    resolver = ConnectorClassDispatcher.repo_controller_resolver(entry.type)
    resolver.get_controller_url(repo_url).redirect_url
  end

  def repo_api_key?(repo_url)
    repo_info = RepoRegistry.repo_db.get(repo_url)
    repo_info && repo_info.metadata.auth_key
  end

end
