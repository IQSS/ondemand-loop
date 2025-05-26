class UploadCollectionsController < ApplicationController
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

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(url_resolution.type)
    processor_params = params.permit(*processor.params_schema).to_h
    processor_params[:object_url] = url_resolution.object_url
    result = processor.create(project, processor_params)
    redirect_back fallback_location: root_path, **result.message
  end

  def edit
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)
    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: t(".invalid_parameters", project_id: project_id, collection_id: collection_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(upload_collection.type)
    processor_params = params.permit(*processor.params_schema).to_h
    result = processor.edit(upload_collection, processor_params)

    render partial: result.partial, layout: false, locals: result.locals
  end

  def update
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)

    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", collection_id: collection_id)
      return
    end

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(upload_collection.type)
    processor_params = params.permit(*processor.params_schema).to_h
    log_info("params", {params: processor_params})
    result = processor.update(upload_collection, processor_params)

    redirect_back fallback_location: root_path, **result.message
  end

  def destroy
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)

    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: t(".not_found", collection_id: collection_id)
      return
    end

    upload_collection.destroy
    redirect_back fallback_location: root_path, notice: t(".success", collection_name: upload_collection.name)
  end

end
