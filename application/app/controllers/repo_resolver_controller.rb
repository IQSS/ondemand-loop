class RepoResolverController < ApplicationController
  include LoggingCommon

  def resolve
    url = params[:url]
    if url.blank?
      redirect_back fallback_location: root_path, alert: 'Please provide repo URL'
      return
    end

    repo_resolver = Repo::RepoResolverService.new(RepoResolversRegistry.resolvers)
    repo_info = repo_resolver.resolve(url)

    #TODO: This needs to be handled by a connector specific class
    if repo_info[:type] === 'dataverse'
      hostname = URI.parse(repo_info[:object_url]).hostname
      redirect_to view_dataverse_dataset_path(dv_hostname: hostname, persistent_id: repo_info[:doi])
    else
      redirect_back fallback_location: root_path, alert: "URL not supported: #{url} type: #{repo_info[:type]}"
    end
  end

end
