class Dataverse::DataversesController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  def index
    hub_registry = Dataverse::HubRegistry.new
    @installations = hub_registry.installations
  end

  def show
    @dataverse_url = current_dataverse_url
    @service = Dataverse::DataverseService.new(@dataverse_url)
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
end