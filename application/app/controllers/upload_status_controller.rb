class UploadStatusController < ApplicationController
  include DetachedProcessStatus
  include LoggingCommon

  def index
    files_provider = Upload::UploadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    uploads = upload_status
    @status = uploads.idle? ? FileStatusSummary.files_summary(@files) : uploads
  end

  def files
    files_provider = Upload::UploadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    uploads = upload_status
    @status = uploads.idle? ? FileStatusSummary.files_summary(@files) : uploads
    render partial: '/upload_status/files', layout: false, locals: { files: @files, status: @status }
  end

end
