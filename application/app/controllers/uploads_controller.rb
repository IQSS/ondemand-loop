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
    @download_file = @project.files.first
    log_info @download_file.to_s, { download_file: @download_file }

    now = Time.now
    persistent_id = "doi:10.5072/FK2/TA1ZIN"
    api_key = "df120162-bde1-44df-8a22-df6e8e596753"
    dataverse_url = "http://host.docker.internal:8080"

    # Initialize UploadFile object
    @upload_file = UploadFile.new.tap do |f|
      f.id = UploadFile.generate_id
      f.project_id = project_id
      f.creation_date = now
      f.type = ConnectorType::DATAVERSE
      f.filename = @download_file.filename
      f.status = FileStatus::PENDING
      f.size = @download_file.size
      f.metadata = {
        dataverse_url: dataverse_url,
        id: persistent_id,
        api_key: api_key,
        filename: @download_file.filename,
        directory_label: "data/subdir1",
        description: "My description",
        size: @download_file.size,
        content_type: @download_file.metadata['content_type'],
        md5: @download_file.metadata['md5'],
        file_location: @download_file.metadata['download_location'], # local path to file
        temp_location: nil
      }
    end
    log_info @upload_file.to_s, { upload_file: @upload_file }
    @upload_file.save

    uploader = Dataverse::HttpUploader.new(@upload_file)
    @response = uploader.upload

    log_info "Upload response code: #{response.code}"
    log_info "Upload response body: #{response.body}"

    #redirect_to :action => :index
  end
end
