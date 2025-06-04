require 'find'

class UploadFilesController < ApplicationController
  include LoggingCommon
  include DateTimeCommon

  def index
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)
    render partial: '/projects/show/upload_files', layout: false, locals: { bundle: upload_bundle }
  end

  # JSON based create method to add a local filepath to an upload bundle
  def create
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    upload_bundle = UploadBundle.find(project_id, upload_bundle_id)
    if upload_bundle.nil?
      head :not_found
      return
    end

    path = params[:path]
    files = list_files(path)
    upload_files = files.map do |file|
      UploadFile.new.tap do |f|
        f.id = UploadFile.generate_id
        f.project_id = project_id
        f.upload_bundle_id = upload_bundle_id
        f.type = ConnectorType::DATAVERSE
        f.creation_date = now
        f.file_location = file.fullpath
        f.filename = file.filename
        f.status = FileStatus::PENDING
        f.size = file.size
      end
    end

    upload_files.each do |file|
      unless file.valid?
        errors = file.errors.full_messages.join(", ")
        log_error('UploadFile validation error', {error: errors, project_id: project_id, upload_bundle_id: upload_bundle_id, file: file.to_s})
        render json: { message: t(".invalid_file", filename: file.filename, errors: errors) }, status: :bad_request
        return
      end
    end

    upload_files.each do |file|
      file.save
      log_info('Added file to upload bundle', {project_id: project_id, upload_bundle_id: upload_bundle_id, file: file.filename})
    end

    message = upload_files.size > 1 ? t(".files_added", count: upload_files.size, path_folder: path_folder) : t(".file_added", filename: upload_files.first.filename)
    render json: { message: message }, status: :ok
  end

  def destroy
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    file_id = params[:id]
    upload_file = UploadFile.find(project_id, upload_bundle_id, file_id)
    if upload_file.nil?
      redirect_back fallback_location: root_path, alert: t(".file_not_found", file_id: file_id, project_id: project_id)
      return
    end

    upload_file.destroy
    redirect_back fallback_location: root_path, notice: t(".upload_file_removed", filename: upload_file.filename)
  end

  def cancel
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    file_id = params[:id]

    if project_id.blank? || upload_bundle_id.blank? || file_id.blank?
      render json: t(".compulsory_fields_error"), status: :bad_request
      return
    end

    file = UploadFile.find(project_id, upload_bundle_id, file_id)

    if file.nil?
      render json: t(".file_not_found", project_id: project_id, upload_bundle_id: upload_bundle_id, file_id: file_id), status: :not_found
      return
    end

    if file.status.uploading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'upload.cancel', body: { project_id: project_id, upload_bundle_id: upload_bundle_id, file_id: file_id})
      response = command_client.request(request)
      return  head :not_found if response.status != 200
    end

    file.update(start_date: now, end_date: now, status: FileStatus::CANCELLED)

    head :no_content
  end

  private

  def list_files(path, limit: 100)
    return [] unless File.exist?(path)

    if File.file?(path)
      return [OpenStruct.new(
        fullpath: File.expand_path(path),
        filename: File.basename(path),
        size: File.size(path)
      )]
    end

    base_path = File.expand_path(path)

    files = []
    Find.find(base_path) do |file|
      raise StandardError, "File size limit exceeded for #{path}" if files.size > limit
      next unless File.file?(file)

      relative_path = file.sub(base_path, '')
      files << OpenStruct.new(
        fullpath: file,
        filename: relative_path,
        size: File.size(file)
      )
    end

    files
  end
end
