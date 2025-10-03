class DownloadFilesController < ApplicationController
  include DateTimeCommon
  include LoggingCommon
  include EventLogger

  before_action :find_file

  def cancel
    previous_status = @file.status.to_s
    if @file.status.downloading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'file.download.cancel', body: {project_id: @file.project_id, file_id: @file.id})
      response = command_client.request(request)
      return redirect_back fallback_location: root_path, alert: t('download_files.file_cancellation_error', filename: @file.filename) if response.status != 200
    end

    if @file.update(status: FileStatus::CANCELLED)
      log_download_file_event(@file, message: 'events.download_file.cancel_completed', metadata: { previous_status: previous_status })
      log_info('Download file cancelled', {id: @file.id, filename: @file.filename})
      redirect_back fallback_location: root_path, notice: t('download_files.file_cancellation_success', filename: @file.filename)
    else
      redirect_back fallback_location: root_path, alert: t('download_files.file_cancellation_update_error', filename: @file.filename)
    end
  end

  def destroy
    if @file.status.downloading?
      redirect_back fallback_location: root_path, alert: t('download_files.file_in_progress', filename: @file.filename)
      return
    end

    @file.destroy
    log_download_file_event(@file, message: 'events.download_file.deleted')
    log_info('Download file deleted', {id: @file.id, filename: @file.filename})
    redirect_back fallback_location: root_path, notice: t('download_files.file_deletion_success', filename: @file.filename)
  end

  def retry
    status = @file.status
    unless FileStatus.retryable_statuses.include?(status)
      return redirect_back fallback_location: root_path, alert: t('download_files.file_retry_invalid', status: status)
    end

    if @file.update(status: FileStatus::PENDING)
      log_download_file_event(@file, message: 'events.download_file.retry_request', metadata: { previous_status: status })
      log_info('Download file retry requested', {id: @file.id, filename: @file.filename})
      redirect_back fallback_location: root_path, notice: t('download_files.file_retry_success', filename: @file.filename)
    else
      redirect_back fallback_location: root_path, alert: t('download_files.file_retry_error', filename: @file.filename)
    end
  end

  private

  def find_file
    project_id = params[:project_id]
    file_id = params[:id]
    @file = DownloadFile.find(project_id, file_id)

    if @file.nil?
      redirect_back fallback_location: root_path, alert: t('download_files.file_not_found', file_id: file_id, project_id: project_id)
    end
  end

end
