class DownloadStatusController < ApplicationController

  def index
    @files = Download::DownloadFilesProvider.new.recent_files
    ScriptLauncher.new.launch_script
  end

  def files
    @files = Download::DownloadFilesProvider.new.recent_files
    render partial: '/download_status/files', layout: false, locals: { files: @files }
  end

end
