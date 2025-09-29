require 'find'

class UploadFilesController < ApplicationController
  include LoggingCommon
  include DateTimeCommon
  include EventLogger

  before_action :find_upload_file, only: [:destroy, :cancel, :retry]
  before_action :find_bundle, only: [:index, :create]

  def index
    render partial: '/projects/show/upload_files', layout: false, locals: { bundle: @upload_bundle }
  end

  # JSON based create method to add a local filepath to an upload bundle
  def create
    path = params[:path]
    files = list_files(path)
    upload_files = files.map do |file|
      UploadFile.new.tap do |f|
        f.id = UploadFile.generate_id
        f.project_id = @upload_bundle.project_id
        f.upload_bundle_id = @upload_bundle.id
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
        log_error('UploadFile validation error', {error: errors, project_id: @upload_bundle.project_id, upload_bundle_id: @upload_bundle.id, file: file.to_s})
        render json: { message: t(".invalid_file", filename: file.filename, errors: errors) }, status: :bad_request
        return
      end
    end

    upload_files.each do |file|
      file.save
      log_info('Added file to upload bundle', {project_id: @upload_bundle.project_id, upload_bundle_id: @upload_bundle.id, file: file.filename})
    end

    message = upload_files.size > 1 ? t(".files_added", count: upload_files.size, path_folder: path) : t(".file_added", filename: upload_files.first.filename)
    render json: { message: message }, status: :ok
  end

  def destroy
    if @upload_file.status.uploading?
      return redirect_back fallback_location: root_path, alert: t(".file_in_progress", filename: @upload_file.filename)
    end

    @upload_file.destroy
    log_upload_file_event(@upload_file, message: 'events.upload_file.deleted')
    log_info('Upload file deleted', {id: @upload_file.id, filename: @upload_file.filename})
    redirect_back fallback_location: root_path, notice: t(".upload_file_removed", filename: @upload_file.filename)
  end

  def cancel
    previous_status = @upload_file.status.to_s
    if @upload_file.status.uploading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'upload.cancel', body: { project_id: @upload_file.project_id, upload_bundle_id: @upload_file.upload_bundle_id, file_id: @upload_file.id})
      response = command_client.request(request)
      return redirect_back fallback_location: root_path, alert: t('.file_cancellation_error', filename: @upload_file.filename) if response.status != 200
    end

    if @upload_file.update(status: FileStatus::CANCELLED)
      log_upload_file_event(@upload_file, message: 'events.upload_file.cancel_completed', metadata: { previous_status: previous_status })
      log_info('Upload file cancelled', {id: @upload_file.id, filename: @upload_file.filename})
      redirect_back fallback_location: root_path, notice: t('.file_cancellation_success', filename: @upload_file.filename)
    else
      redirect_back fallback_location: root_path, notice: t('.file_cancellation_update_error', filename: @upload_file.filename)
    end
  end

  def retry
    status = @upload_file.status
    unless FileStatus.retryable_statuses.include?(status)
      return redirect_back fallback_location: root_path, alert: t('.file_retry_invalid', status: status)
    end
    if @upload_file.update(status: FileStatus::PENDING)
      log_upload_file_event(@upload_file, message: 'events.upload_file.retry_request', metadata: { previous_status: status })
      log_info('Upload file retry requested', {id: @upload_file.id, filename: @upload_file.filename})
      redirect_back fallback_location: root_path, notice: t('.file_retry_success', filename: @upload_file.filename)
    else
      redirect_back fallback_location: root_path, alert: t('.file_retry_error', filename: @upload_file.filename)
    end
  end

  private

  def find_upload_file
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    file_id = params[:id]
    @upload_file = UploadFile.find(project_id, upload_bundle_id, file_id)

    if @upload_file.nil?
       redirect_back fallback_location: root_path, alert: t("upload_files.file_not_found", project_id: project_id, upload_bundle_id: upload_bundle_id, file_id: file_id)
       return
    end
  end

  def find_bundle
    project_id = params[:project_id]
    upload_bundle_id = params[:upload_bundle_id]
    @upload_bundle = UploadBundle.find(project_id, upload_bundle_id)

    if @upload_bundle.nil?
      message = t("upload_files.bundle_not_found", project_id: project_id, upload_bundle_id: upload_bundle_id)
      if ajax_request?
        render json: { message: message }, status: :not_found
      else
        redirect_back fallback_location: root_path, alert: message
      end
      return
    end
  end

  def list_files(path, limit: 100)
    return [] unless File.exist?(path)

    if File.file?(path)
      return [OpenStruct.new(
        fullpath: File.expand_path(path),
        filename: File.join('/', File.basename(path)),
        size: File.size(path)
      )]
    end

    base_path = File.expand_path(path)
    parent_dir = File.dirname(base_path)

    files = []
    Find.find(base_path) do |file|
      raise StandardError, "File size limit exceeded for #{path}" if files.size > limit
      next unless File.file?(file)

      relative_path = file.sub(parent_dir, '')
      files << OpenStruct.new(
        fullpath: file,
        filename: relative_path,
        size: File.size(file)
      )
    end

    files
  end
end
