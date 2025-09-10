class DownloadFilesController < ApplicationController
  include DateTimeCommon
  include LoggingCommon
  include EventLogger

  def cancel
    project_id = params[:project_id]
    file_id = params[:id]
    file = DownloadFile.find(project_id, file_id)

    if file.nil?
      return redirect_back fallback_location: root_path, alert: t('download_files.file_not_found', file_id: file_id, project_id: project_id)
    end

    previous_status = file.status.to_s
    if file.status.downloading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'download.cancel', body: {project_id: project_id, file_id: file_id})
      response = command_client.request(request)
      return redirect_back fallback_location: root_path, alert: t('download_files.file_cancellation_error', filename: file.filename) if response.status != 200
    end

    if file.update(status: FileStatus::CANCELLED)
      log_download_file_event(file, message: 'events.download_file.cancel_completed', metadata: { 'filename' => file.filename, 'previous_status' => previous_status })
      redirect_back fallback_location: root_path, notice: t('download_files.file_cancellation_success', filename: file.filename)
    else
      redirect_back fallback_location: root_path, alert: t('download_files.file_cancellation_update_error', filename: file.filename)
    end
  end

  def update
    project_id = params[:project_id]
    file_id = params[:id]
    state = params[:state]
    file = DownloadFile.find(project_id, file_id)

    if file.nil?
      redirect_back fallback_location: root_path, alert: t('download_files.file_not_found', file_id: file_id, project_id: project_id)
      return
    end

    if file.update(status: FileStatus.get(state))
      redirect_back fallback_location: root_path, notice: t('download_files.file_update_success', filename: file.filename)
    else
      redirect_back fallback_location: root_path, alert: t('download_files.file_update_error', filename: file.filename)
    end
  end

  def destroy
    project_id = params[:project_id]
    file_id = params[:id]
    file = DownloadFile.find(project_id, file_id)
    if file.nil?
      redirect_back fallback_location: root_path, alert: t('download_files.file_not_found', file_id: file_id, project_id: project_id)
      return
    end

    if file.status.downloading?
      redirect_back fallback_location: root_path, alert: t('download_files.file_in_progress', filename: file.filename)
      return
    end

    file.destroy
    redirect_back fallback_location: root_path, notice: t('download_files.file_deletion_success', filename: file.filename)
  end

end
