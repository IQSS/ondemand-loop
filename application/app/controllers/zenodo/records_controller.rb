class Zenodo::RecordsController < ApplicationController
  include LoggingCommon

  before_action :init_service
  before_action :find_dataset
  before_action :init_project_service, only: [:download]

  def show; end

  def download
    file_ids = params[:file_ids] || []
    project = Project.find(params[:project_id])
    if project.nil?
      project = @project_service.initialize_project
      unless project.save
        errors = project.errors.full_messages.join(", ")
        redirect_back fallback_location: root_path, alert: t(".error_generating_project", errors: errors)
        return
      end
    end

    download_files = @project_service.initialize_download_files(project, @dataset, file_ids)
    download_files.each do |file|
      unless file.valid?
        errors = file.errors.full_messages.join(', ')
        redirect_back fallback_location: root_path, alert: t('.invalid_file_in_selection', filename: file.filename, errors: errors)
        return
      end
    end
    save_results = download_files.map(&:save)
    if save_results.include?(false)
      redirect_back fallback_location: root_path, alert: t('.error_generating_the_download_file')
      return
    end
    redirect_back fallback_location: root_path, notice: t('.files_added_to_project', project_name: project.name)
  end

  private

  def init_service
    @service = Zenodo::RecordService.new
  end

  def init_project_service
    @project_service = Zenodo::ProjectService.new
  end

  def find_dataset
    @record_id = params[:record_id]
    @record = @service.find_record(@record_id)
    unless @record
      flash[:alert] = t('.record_not_found', record_id: @record_id)
      redirect_to root_path
    end
  rescue => e
    log_error('Zenodo record error', { record_id: @record_id }, e)
    flash[:alert] = t('.record_service_error', record_id: @record_id)
    redirect_to root_path
  end
end
