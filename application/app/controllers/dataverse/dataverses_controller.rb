class Dataverse::DataversesController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  before_action :get_dv_full_hostname
  before_action :init_service

  def show
    begin
      @page = params[:page] ? params[:page].to_i : 1
      @dataverse = @service.find_dataverse_by_id(params[:id])
      @search_result = @service.search_dataverse_items(params[:id], @page)
      if @dataverse.nil? || @search_result.nil?
        log_error('Dataverse not found.', {dataverse: @dataverse_url, id: params[:id]})
        flash[:error] = "Dataverse not found. Dataverse: #{@dataverse_url} Id: #{params[:id]}"
        redirect_to root_path
        return
      end
    rescue Exception => e
      log_error('Dataverse service error', {dataverse: @dataverse_url, id: params[:id]}, e)
      flash[:error] = "Dataverse service error. Dataverse: #{@dataverse_url} Id: #{params[:id]}"
      redirect_to root_path
    end
  end

  private

  def get_dv_full_hostname
    @dataverse_url = current_dataverse_url
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_url)
  end
end