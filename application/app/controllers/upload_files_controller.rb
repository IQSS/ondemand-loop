require 'find'

class UploadFilesController < ApplicationController
  include LoggingCommon
  include DateTimeCommon

  def files
    project_id = params[:project_id]
    collection_id = params[:collection_id]
    upload_collection = UploadCollection.find(project_id, collection_id)
    render partial: '/projects/show/upload_files', layout: false, locals: { collection: upload_collection }
  end

  def add
    project_id = params[:project_id]
    collection_id = params[:collection_id]
    upload_collection = UploadCollection.find(project_id, collection_id)
    if upload_collection.nil?
      head :not_found
      return
    end


    path = params[:path]
    files = list_files(path)
    files.each do |file|
      upload_file = UploadFile.new.tap do |f|
        f.id = UploadFile.generate_id
        f.project_id = project_id
        f.collection_id = collection_id
        f.type = ConnectorType::DATAVERSE
        f.creation_date = now
        f.file_location = file.fullpath
        f.filename = file.filename
        f.status = FileStatus::PENDING
        f.size = file.size
      end
      upload_file.save
      log_info('Add path to upload collection', {project_id: project_id, collection_id: collection_id, file: file})
    end

    head :ok
  end

  def delete_file
    project_id = params[:project_id]
    collection_id = params[:collection_id]
    file_id = params[:file_id]
    upload_file = UploadFile.find(project_id, collection_id, file_id)
    if upload_file.nil?
      redirect_back fallback_location: root_path, alert: "File: #{file_id} not found for project: #{project_id}"
      return
    end

    upload_file.destroy
    redirect_back fallback_location: root_path, notice: "Upload file removed from collection. #{upload_file.filename}"
  end

  def create_collection
    project_id = params[:project_id]
    project = Project.find(project_id)
    if project.nil?
      redirect_back fallback_location: root_path, alert: "Invalid project id: #{project_id}"
      return
    end

    temp_param = params[:dataset_url]
    dataset_url, repo_key = temp_param.to_s.strip.split(/\s+/, 2)
    repo_url = Repo::RepoUrlParser.parse(dataset_url)
    if repo_url.nil? || repo_url.domain.blank? || repo_url.doi.blank?
      redirect_back fallback_location: root_path, alert: "Invalid dataset URL: #{dataset_url}"
      return
    end

    file_utils = Common::FileUtils.new
    upload_collection = UploadCollection.new.tap do |c|
      c.id = file_utils.normalize_name(File.join(repo_url.domain, UploadCollection.generate_code))
      c.project_id = project_id
      c.creation_date = now
      c.type = ConnectorType::DATAVERSE
      c.name = repo_url.domain
      c.metadata = {
        dataverse_url: repo_url.repo_url,
        persistent_id: repo_url.doi,
        api_key: repo_key
      }
    end
    upload_collection.save
    log_info('Upload collection created', {upload_collection: upload_collection})
    redirect_back fallback_location: root_path, notice: "Upload Collection created: #{upload_collection.name}"
  end

  def cancel
    project_id = params[:project_id]
    collection_id = params[:collection_id]
    file_id = params[:file_id]

    if project_id.blank? || collection_id.blank? || file_id.blank?
      render json: 'project_id and file_id are compulsory', status: :bad_request
      return
    end

    file = UploadFile.find(project_id, collection_id, file_id)

    if file.nil?
      render json: "file not found project_id=#{project_id} collection_id=#{collection_id} file_id=#{file_id}", status: :not_found
      return
    end

    if file.status.uploading?
      command_client = Command::CommandClient.new(socket_path: ::Configuration.download_server_socket_file)
      request = Command::Request.new(command: 'cancel.upload', body: {project_id: project_id, collection_id: collection_id, file_id: file_id})
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
