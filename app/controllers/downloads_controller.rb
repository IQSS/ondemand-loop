class DownloadsController < ApplicationController
  ALLOWED_ACTIONS = %w[index collections].freeze

  before_action :validate_method_name

  def dynamic_action
    send(params[:action]) # Call the validated method dynamically
  end

  def index
    @download_collections = DownloadCollection.all
    DetachProcess.new.start_process
  end

  def collections
    @download_collections = DownloadCollection.all
    render partial: '/downloads/collections', layout: false
  end

  private

  def validate_method_name
    unless ALLOWED_ACTIONS.include?(params[:action])
      render plain: "Invalid method", status: :not_found
    end
  end
end
