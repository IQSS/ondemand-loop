class FilesController < ApplicationController
  include DateTimeCommon

  def cancel
    collection_id = params[:collection_id]
    file_id = params[:file_id]

    if collection_id.blank? || file_id.blank?
      render json: 'project_id and file_id are compulsory', status: :bad_request
      return
    end

    file = DownloadFile.find(collection_id, file_id)

    if file.nil?
      render json: "file not found collection_id=#{collection_id} file_id=#{file_id}", status: :not_found
      return
    end

    if file.status.downloading?
      command_client = Download::Command::DownloadCommandClient.new(socket_path: ::Configuration.download_server_socket_file)
      request = Download::Command::Request.new(command: 'cancel', body: {collection_id: collection_id, file_id: file_id})
      response = command_client.request(request)
      return  head :not_found if response.status != 200
    end

    file.update(start_date: now, end_date: now, status: FileStatus::CANCELLED)
    file.save

    head :no_content
  end

end
