class RepoResolverController < ApplicationController
  include LoggingCommon

  def resolve
    url = params[:url]
    if url.blank?
      redirect_back fallback_location: root_path, alert: t(".blank_url_error")
      return
    end

    repo_resolver = Repo::RepoResolverService.new(RepoResolversRegistry.resolvers)
    repo_info = repo_resolver.resolve(url)

    #TODO: This needs to be handled by a connector specific class
    if repo_info[:type] === 'dataverse'
      repo_url = Repo::RepoUrlParser.parse(repo_info[:object_url])
      dv_scheme = 'http' if repo_url.scheme != 'https'

      redirect_to view_dataverse_dataset_path(dv_hostname: repo_url.domain, persistent_id: repo_info[:doi], dv_scheme: dv_scheme, dv_port: repo_url.port)
    else
      redirect_back fallback_location: root_path, alert: t(".url_not_supported", url: url, type: repo_info[:type])
    end
  end

end
