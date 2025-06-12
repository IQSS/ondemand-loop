class DownloadStatusController < ApplicationController
  include DetachedProcessStatus

  def index
    files_provider = Download::DownloadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    downloads = download_status
    @status = downloads.idle? ? from_download_files_summary(@summary) : downloads

  end

  def files
    files_provider = Download::DownloadFilesProvider.new
    @files = files_provider.recent_files
    @summary = FileStatusSummary.compute_summary(@files.map(&:file))
    downloads = download_status
    @status = downloads.idle? ? from_download_files_summary(@summary) : downloads
    render partial: '/download_status/files', layout: false, locals: { files: @files }
  end

end
