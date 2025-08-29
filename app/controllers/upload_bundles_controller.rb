class UploadBundlesController < ApplicationController
  include LoggingCommon
  include TabsHelper

  def update
    project_id = project_id_param
    upload_bundle_id = params[:id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)
    if upload_bundle.nil?
      error_message = t('.not_found', upload_bundle_id: upload_bundle_id)
      log_error('Upload bundle not found', { project_id: project_id, upload_bundle_id: upload_bundle_id })
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: error_message }
        format.json { render json: { error: error_message }, status: :not_found }
      end
      return
    end

    update_params = params.permit(:name).to_h.compact

    if upload_bundle.update(update_params)
      log_info('Upload bundle updated successfully', { project_id: project_id, upload_bundle_id: upload_bundle_id })
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: t('.success', bundle_name: upload_bundle.name) }
        format.json { render json: upload_bundle.to_json, status: :ok }
      end
    else
      log_error('Unable to update upload bundle', { project_id: project_id, upload_bundle_id: upload_bundle_id, errors: upload_bundle.errors.full_messages })
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: t('.error', errors: upload_bundle.errors.full_messages) }
        format.json { render json: { error: upload_bundle.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    project_id = project_id_param
    upload_bundle_id = params[:id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)

    if upload_bundle.nil?
      log_error('Upload bundle not found for destroy', { project_id: project_id, upload_bundle_id: upload_bundle_id })
      redirect_back fallback_location: root_path, alert: t('.not_found', upload_bundle_id: upload_bundle_id)
      return
    end

    upload_bundle.destroy
    log_info('Upload bundle destroyed', { project_id: project_id, upload_bundle_id: upload_bundle_id })
    redirect_back fallback_location: root_path, notice: t('.success', bundle_name: upload_bundle.name)
  end

  private

  def project_id_param
    param = params[:project_id]
    param == ':project_id' ? request.request_parameters[:project_id] : param
  end
end
