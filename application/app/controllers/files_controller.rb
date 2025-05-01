class FilesController < ApplicationController
  include DateTimeCommon

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
      command_client = Download::Command::DownloadCommandClient.new(socket_path: ::Configuration.download_server_socket_file)
      request = Download::Command::Request.new(command: 'cancel', body: {project_id: project_id, file_id: file_id})
      response = command_client.request(request)
      return  head :not_found if response.status != 200
    end

    file.update(start_date: now, end_date: now, status: FileStatus::CANCELLED)

    head :no_content
  end

end
