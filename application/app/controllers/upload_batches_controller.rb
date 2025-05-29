class UploadBatchesController < ApplicationController
  include LoggingCommon

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

    if url_resolution.unknown?
      redirect_back fallback_location: root_path,  alert: t(".invalid_repo", url: repo_url)
      return
    end

    processor = ConnectorClassDispatcher.upload_batch_connector_processor(url_resolution.type)
    processor_params = params.permit(*processor.params_schema).to_h
    processor_params[:object_url] = url_resolution.object_url
    result = processor.create(project, processor_params)
    redirect_back fallback_location: root_path, **result.message
  end

  def edit
    project_id = params[:project_id]
    upload_batch_id = params[:id]
    upload_batch = UploadBatch.find(project_id, upload_batch_id)
    if upload_batch.nil?
      redirect_back fallback_location: root_path, alert: t(".invalid_parameters", project_id: project_id, upload_batch_id: upload_batch_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_batch_connector_processor(upload_batch.type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.edit(upload_batch, processor_params)

    render partial: result.partial, layout: false, locals: result.locals
  end

  def update
    project_id = params[:project_id]
    upload_batch_id = params[:id]
    upload_batch = UploadBatch.find(project_id, upload_batch_id)

    if upload_batch.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", upload_batch_id: upload_batch_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_batch_connector_processor(upload_batch.type)
    processor_params = params.permit(*processor.params_schema).to_h
    log_info("params", {params: processor_params})
    result = processor.update(upload_batch, processor_params)

    redirect_back fallback_location: root_path, **result.message
  end

  def destroy
    project_id = params[:project_id]
    upload_batch_id = params[:id]
    upload_batch = UploadBatch.find(project_id, upload_batch_id)

    if upload_batch.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", upload_batch_id: upload_batch_id)
      return
    end

    upload_batch.destroy
    redirect_back fallback_location: root_path, notice: t(".success", batch_name: upload_batch.name)
  end

end
