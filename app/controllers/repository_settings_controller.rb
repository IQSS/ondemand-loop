class RepositorySettingsController < ApplicationController
  def index
    @repositories = RepoRegistry.repo_db.all
  end

  def create
    repo_url = params[:repo_url].to_s.strip
    if repo_url.blank?
      redirect_to repository_settings_path, alert: t('.message_invalid_request', url: repo_url) and return
    end

    repo_resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = repo_resolver.resolve(repo_url)

    if result.unknown?
      redirect_to repository_settings_path, alert: t('.message_invalid_url', url: repo_url) and return
    end

    redirect_to repository_settings_path, notice: t('.message_success', url: result.object_url, type: result.type.to_s)
  end

  def update
    repo_url = params[:repo_url]
    repo = RepoRegistry.repo_db.get(repo_url)
    unless repo
      redirect_to repository_settings_path, alert: t('.message_not_found', domain: repo_url) and return
    end

    processor = ConnectorClassDispatcher.repository_settings_processor(repo.type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.update(repo, processor_params)

    redirect_to repository_settings_path, **result.message
  end

  def destroy
    repo_url = params[:repo_url].to_s.strip
    repo = RepoRegistry.repo_db.get(repo_url)
    unless repo
      redirect_to repository_settings_path, alert: t('.message_not_found', domain: repo_url) and return
    end

    RepoRegistry.repo_db.delete(repo_url)
    redirect_to repository_settings_path, notice: t('.message_deleted', domain: repo_url, type: repo.type.to_s)
  end
end
