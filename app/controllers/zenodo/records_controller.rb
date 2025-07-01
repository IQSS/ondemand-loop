class Zenodo::RecordsController < ApplicationController
  include LoggingCommon

  before_action :init_service
  before_action :find_record
  before_action :init_project_service, only: [:download]

  def show; end

  def download
    file_ids = params[:file_ids] || []
    project = Project.find(params[:project_id])
    if project.nil?
      project = @project_service.initialize_project
      unless project.save
        errors = project.errors.full_messages.join(", ")
        redirect_back fallback_location: root_path, alert: t("zenodo.records.download.message_project_error", errors: errors)
        return
      end
    end

    download_files = @project_service.initialize_download_files(project, @record, file_ids)
    download_files.each do |file|
      unless file.valid?
        errors = file.errors.full_messages.join(', ')
        redirect_back fallback_location: root_path, alert: t('zenodo.records.download.message_validation_file_error', filename: file.filename, errors: errors)
        return
      end
    end
    save_results = download_files.map(&:save)
    if save_results.include?(false)
      redirect_back fallback_location: root_path, alert: t('zenodo.records.download.message_save_file_error')
      return
    end
    redirect_back fallback_location: root_path, notice: t('zenodo.records.download.message_success', project_name: project.name)
  end

  private

  def init_service
    @service = Zenodo::RecordService.new
  end

  def init_project_service
    @project_service = Zenodo::ProjectService.new
  end

  def find_record
    @record_id = params[:id]
    @record = @service.find_record(@record_id)
    unless @record
      redirect_to root_path, alert: t('zenodo.records.message_record_not_found', record_id: @record_id)
    end
  rescue => e
    log_error('Find record error', { record_id: @record_id }, e)
    redirect_to root_path, alert: t('zenodo.records.message_record_service_error', record_id: @record_id)
  end
end
