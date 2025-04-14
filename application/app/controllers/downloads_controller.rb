class DownloadsController < ApplicationController

  def index
    @download_collections = DownloadCollection.all
    DetachProcess.new.start_process
  end

  def collections
    @download_collections = DownloadCollection.all
    render partial: '/downloads/collections', layout: false
  end

end
