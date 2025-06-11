class DownloadStatusController < ApplicationController
  include DetachedProcessStatus

  def index
    files_provider = Download::DownloadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    downloads = download_status
    @status = downloads.idle? ? FileStatusSummary.files_summary(@files) : downloads

  end

  def files
    files_provider = Download::DownloadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    downloads = download_status
    @status = downloads.idle? ? FileStatusSummary.files_summary(@files) : downloads
    render partial: '/download_status/files', layout: false, locals: { files: @files }
  end

end
