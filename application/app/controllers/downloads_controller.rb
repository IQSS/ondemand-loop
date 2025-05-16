class DownloadsController < ApplicationController

  def index
    @files = Download::DownloadFilesProvider.new.recent_files
    ScriptLauncher.new.start_process
  end

  def files
    @files = Download::DownloadFilesProvider.new.recent_files
    render partial: '/downloads/files', layout: false, locals: { files: @files }
  end

end
