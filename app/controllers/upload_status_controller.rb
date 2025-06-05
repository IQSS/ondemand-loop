class UploadStatusController < ApplicationController
  include LoggingCommon

  def index
    @files = Upload::UploadFilesProvider.new.recent_files
    ScriptLauncher.new.launch_script
  end

  def files
    @files = Upload::UploadFilesProvider.new.recent_files
    render partial: '/upload_status/files', layout: false, locals: { files: @files }
  end

end
