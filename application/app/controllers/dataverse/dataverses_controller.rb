class Dataverse::DataversesController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  def index
    begin
      hub_registry = DataverseHubRegistry.registry
      installations = hub_registry.installations
      page = params[:page] ? params[:page].to_i : 1
      @installations_page = Page.new(installations, page, 25)
    rescue Exception => e
      log_error('Dataverse Installations service error', {}, e)
      flash[:alert] = t(".dataverse_installations_service_error")
      redirect_to root_path
    end
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
        flash[:alert] = t(".dataverse_not_found", dataverse_url: @dataverse_url, id: params[:id])
        redirect_to root_path
        return
      end
    rescue Dataverse::DataverseService::UnauthorizedException => e
      log_error('Dataverse requires authorization', {dataverse: @dataverse_url, id: params[:id]}, e)
      flash[:alert] = t(".dataverse_requires_authorization", dataverse_url: @dataverse_url, id: params[:id])
      redirect_to root_path
    rescue Exception => e
      log_error('Dataverse service error', {dataverse: @dataverse_url, id: params[:id]}, e)
      flash[:alert] = t(".dataverse_service_error", dataverse_url: @dataverse_url, id: params[:id])
      redirect_to root_path
    end
  end
end