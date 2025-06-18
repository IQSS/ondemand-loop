class DetachedProcessController < ApplicationController
  include DetachedProcessStatus
  include LoggingCommon

  def status
    downloads = download_status
    uploads = upload_status
    ScriptLauncher.new(Download::DownloadFilesProvider.new, Upload::UploadFilesProvider.new).launch_script
    render partial: 'file_activity_status', layout: false, locals: { download_status: downloads, upload_status: uploads }
  end

end