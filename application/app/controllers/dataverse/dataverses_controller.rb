class Dataverse::DataversesController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  before_action :get_dv_full_hostname
  before_action :init_service

  def show
    @page = params[:page] ? params[:page].to_i : 1
    @dataverse = @service.find_dataverse_by_id(params[:id])
    @search_result = @service.search_dataverse_items(params[:id], @page)
  end

  private

  def get_dv_full_hostname
    @dataverse_url = current_dataverse_url
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_url)
  end
end