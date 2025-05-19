class UploadCollectionsController < ApplicationController
  include LoggingCommon

  def create
    project_id = params[:project_id]
    project = Project.find(project_id)
    if project.nil?
      redirect_back fallback_location: root_path, alert: "Invalid project id: #{project_id}"
      return
    end

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(ConnectorType::DATAVERSE)
    result = processor.create(project, collection_params)
    flash_message = result[:message] || {}
    redirect_back fallback_location: root_path, **flash_message
  end

  def edit
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)
    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: "Invalid parameters project_id: #{project_id} collection_id: #{collection_id}"
      return
    end

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(upload_collection.type)
    result = processor.edit(upload_collection)
    render partial: result.partial, layout: false, locals: result.locals
  end

  def update
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)

    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: "Upload Collection not found: #{collection_id}"
      return
    end

    processor = ConnectorClassDispatcher.upload_collection_connector_processor(upload_collection.type)
    result = processor.update(upload_collection, collection_params)

    flash_message = result[:message] || {}
    redirect_back fallback_location: root_path, **flash_message
  end

  def destroy
    project_id = params[:project_id]
    collection_id = params[:id]
    upload_collection = UploadCollection.find(project_id, collection_id)

    if upload_collection.nil?
      redirect_back fallback_location: root_path, alert: "Upload Collection not found: #{collection_id}"
      return
    end

    upload_collection.destroy
    redirect_back fallback_location: root_path, notice: "Upload collection deleted: #{upload_collection.name}"
  end

  private

  def collection_params
    return {} unless params[:collection].present?

    params.require(:collection).permit!.to_h
  end
end
