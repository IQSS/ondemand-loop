class ProjectsController < ApplicationController

  def index
    @download_collections = DownloadCollection.all
  end
end
