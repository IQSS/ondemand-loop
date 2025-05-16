class UploadsController < ApplicationController
  include LoggingCommon

  def index
    @files = Upload::UploadFilesProvider.new.recent_files
    ScriptLauncher.new.launch_script
  end

  def files
    @files = Upload::UploadFilesProvider.new.recent_files
    render partial: '/uploads/files', layout: false, locals: { files: @files }
  end

end
