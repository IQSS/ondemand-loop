class UploadsController < ApplicationController
  include LoggingCommon

  def index
    @files = Upload::UploadFilesProvider.new.recent_files
    DetachProcess.new.start_process
  end

  def files
    @files = Upload::UploadFilesProvider.new.recent_files
    render partial: '/uploads/files', layout: false, locals: { files: @files }
  end

  def create
    @project = Project.all.first
    project_id = @project.id
    @download_file = @project.files.select{|f| f.status.success?}.first
    log_info @download_file.to_s, { download_file: @download_file }

    now = '2025-05-07T09:59:20'
    persistent_id = ""
    api_key = ""
    dataverse_url = ""

    @upload_collection = UploadCollection.new.tap do |c|
      c.id = UploadCollection.generate_id
      c.project_id = project_id
      c.creation_date = now
      c.type = ConnectorType::DATAVERSE
      c.metadata = {
        dataverse_url: dataverse_url,
        persistent_id: persistent_id,
        api_key: api_key
      }
    end
    @upload_collection.save
    log_info @upload_collection.to_s, {upload_collection: @upload_collection, now: now}

    # Initialize UploadFile object
    @upload_file = UploadFile.new.tap do |f|
      f.id = UploadFile.generate_id
      f.project_id = project_id
      f.collection_id = @upload_collection.id
      f.creation_date = now
      f.type = ConnectorType::DATAVERSE
      f.file_location = @download_file.metadata['download_location']
      f.filename = @download_file.filename
      f.status = FileStatus::PENDING
      f.size = @download_file.size
    end
    log_info @upload_file.to_s, { upload_file: @upload_file }
    @upload_file.save

    redirect_to :action => :index
  end
end
