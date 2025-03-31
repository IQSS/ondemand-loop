class DownloadsController < ApplicationController
  def index
    @download_collections = DownloadCollection.all
    DetachProcess.new.start_process
  end
end
