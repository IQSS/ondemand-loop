class DownloadFilesController < ApplicationController
  include DateTimeCommon
  include LoggingCommon

  def cancel
    project_id = params[:project_id]
    file_id = params[:file_id]

    if project_id.blank? || file_id.blank?
      render json: 'project_id and file_id are compulsory', status: :bad_request
      return
    end

    file = DownloadFile.find(project_id, file_id)

    if file.nil?
      render json: "file not found project_id=#{project_id} file_id=#{file_id}", status: :not_found
      return
    end

    if file.status.downloading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.download_server_socket_file)
      request = Command::Request.new(command: 'download.cancel', body: {project_id: project_id, file_id: file_id})
      response = command_client.request(request)
      return  head :not_found if response.status != 200
    end

    file.update(start_date: now, end_date: now, status: FileStatus::CANCELLED)

    head :no_content
  end

  def destroy
    project_id = params[:project_id]
    file_id = params[:file_id]
    file = DownloadFile.find(project_id, file_id)
    if file.nil?
      redirect_to projects_path, alert: "File: #{file_id} not found for project: #{project_id}"
      return
    end

    file.destroy
    redirect_to projects_path, notice: 'Download file deleted successfully'
  end

end
