class Dataverse::DataversesController < ApplicationController
  include LoggingCommon

  before_action :get_dv_full_hostname
  before_action :init_service

  def index
    @dataverse = @service.find_dataverse_by_id(":root")
    @search_result = @service.search_dataverse_items(":root")
    @items = @search_result.data.items
  end

  private

  def get_dv_full_hostname
    if params[:dv_hostname]
      hostname = params[:dv_hostname]
      scheme = params[:dv_scheme] || "https"
      port = params[:dv_port] || 443
      @dataverse_url = URI.parse(scheme + "://" + hostname + ":" + port.to_s).to_s
    else
      flash[:error] = "Invalid Dataverse Hostname"
      redirect_to downloads_path
      return
    end
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_url)
  end
end