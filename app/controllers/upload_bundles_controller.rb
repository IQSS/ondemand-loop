class UploadBundlesController < ApplicationController
  include LoggingCommon
  include TabsHelper

  def create
    project_id = params[:project_id]
    project = Project.find(project_id)
    if project.nil?
      redirect_back fallback_location: root_path, alert: t(".invalid_project", id: project_id)
      return
    end

    repo_url = params[:remote_repo_url]
    repo_resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    url_resolution = repo_resolver.resolve(repo_url)
    log_info('Remote Repo resolution', { repo_url: repo_url, type: url_resolution.type })

    if url_resolution.unknown?
      redirect_back fallback_location: root_path,  alert: t(".invalid_repo", url: repo_url)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(url_resolution.type)
    processor_params = params.permit(*processor.params_schema).to_h
    processor_params[:object_url] = url_resolution.object_url
    result = processor.create(project, processor_params)
    params[:anchor] ||= tab_anchor_for(result.resource)

    redirect_back fallback_location: root_path, **result.message
  end

  def edit
    project_id = params[:project_id]
    upload_bundle_id = params[:id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)
    if upload_bundle.nil?
      redirect_back fallback_location: root_path, alert: t(".invalid_parameters", project_id: project_id, upload_bundle_id: upload_bundle_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(upload_bundle.type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.edit(upload_bundle, processor_params)

    render partial: result.partial, layout: false, locals: result.locals
  end

  def update
    project_id = params[:project_id]
    upload_bundle_id = params[:id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)

    if upload_bundle.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", upload_bundle_id: upload_bundle_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(upload_bundle.type)
    processor_params = params.permit(*processor.params_schema).to_h
    log_info("params", {params: processor_params})
    result = processor.update(upload_bundle, processor_params)

    redirect_back fallback_location: root_path, **result.message
  end

  def destroy
    project_id = params[:project_id]
    upload_bundle_id = params[:id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)

    if upload_bundle.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", upload_bundle_id: upload_bundle_id)
      return
    end

    upload_bundle.destroy
    redirect_back fallback_location: root_path, notice: t(".success", bundle_name: upload_bundle.name)
  end

end
