class DownloadFilesController < ApplicationController
  include DateTimeCommon
  include LoggingCommon

  def cancel
    project_id = params[:project_id]
    file_id = params[:id]
    file = DownloadFile.find(project_id, file_id)

    if file.nil?
      render json: t('.file_not_found_for_project', file_id: file_id, project_id: project_id), status: :not_found
      return
    end

    if file.status.downloading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'download.cancel', body: {project_id: project_id, file_id: file_id})
      response = command_client.request(request)
      return  head :not_found if response.status != 200
    end

    file.update(start_date: now, end_date: now, status: FileStatus::CANCELLED)

    head :no_content
  end

  def destroy
    project_id = params[:project_id]
    file_id = params[:id]
    file = DownloadFile.find(project_id, file_id)
    if file.nil?
      redirect_back fallback_location: root_path, alert: t('.file_not_found_for_project', file_id: file_id, project_id: project_id)
      return
    end

    if file.status.downloading?
      redirect_back fallback_location: root_path, alert: t(".file_in_progress", filename: file.filename)
      return
    end

    file.destroy
    redirect_back fallback_location: root_path, notice: t('.download_file_deleted_successfully', filename: file.filename)
  end

end
