class UploadBundlesConnectorController < ApplicationController
  include LoggingCommon
  include TabsHelper

  def create
    project_id = project_id_param
    project = Project.find(project_id)
    if project.nil?
      log_error('Invalid project', { project_id: project_id })
      redirect_back fallback_location: root_path, alert: t('upload_bundles.create.invalid_project', id: project_id)
      return
    end

    repo_url = params[:remote_repo_url]
    repo_resolver = ::Configuration.repo_resolver_service
    url_resolution = repo_resolver.resolve(repo_url)
    log_info('Remote Repo resolution', { repo_url: repo_url, type: url_resolution.type })

    if url_resolution.unknown?
      log_error('Unknown repository URL', { repo_url: repo_url })
      redirect_back fallback_location: root_path,  alert: t('upload_bundles.create.invalid_repo', url: repo_url)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(url_resolution.type)
    processor_params = params.permit(*processor.params_schema).to_h
    processor_params[:object_url] = url_resolution.object_url
    result = processor.create(project, processor_params)
    anchor = params[:anchor]
    anchor ||= tab_anchor_for(result.resource) if result.resource

    log_info('Upload bundle created', { project_id: project_id, upload_bundle_id: result.resource&.id })
    redirect_to project_path(id: project_id, anchor: anchor), **result.message
  end

  def edit
    project_id = project_id_param
    upload_bundle_id = params[:upload_bundle_id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)
    if upload_bundle.nil?
      log_error('Invalid parameters for edit', { project_id: project_id, upload_bundle_id: upload_bundle_id })
      redirect_back fallback_location: root_path, alert: t('upload_bundles.edit.invalid_parameters', project_id: project_id, upload_bundle_id: upload_bundle_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(upload_bundle.type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.edit(upload_bundle, processor_params)

    log_info('Rendering connector edit', { project_id: project_id, upload_bundle_id: upload_bundle_id, template: result.template })
    render partial: result.template, layout: false, locals: result.locals
  end

  def update
    project_id = project_id_param
    upload_bundle_id = params[:upload_bundle_id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)

    if upload_bundle.nil?
      log_error('Upload bundle not found', { project_id: project_id, upload_bundle_id: upload_bundle_id })
      redirect_back fallback_location: root_path, alert: t('upload_bundles.update.not_found', upload_bundle_id: upload_bundle_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_bundle_connector_processor(upload_bundle.type)
    processor_params = params.permit(*processor.params_schema).to_h
    log_info('Updating upload bundle via connector', { project_id: project_id, upload_bundle_id: upload_bundle_id, params: processor_params })
    result = processor.update(upload_bundle, processor_params)

    redirect_back fallback_location: root_path, **result.message
  end

  private

  def project_id_param
    param = params[:project_id]
    param == ':project_id' ? request.request_parameters[:project_id] : param
  end
end
