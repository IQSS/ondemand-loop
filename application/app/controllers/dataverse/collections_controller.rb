class Dataverse::CollectionsController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  def show
    @dataverse_url = current_dataverse_url
    @service = Dataverse::CollectionService.new(@dataverse_url)
    begin
      @page = params[:page] ? params[:page].to_i : 1
      @dataverse = @service.find_collection_by_id(params[:id])
      @search_result = @service.search_collection_items(params[:id], page: @page)
      if @dataverse.nil? || @search_result.nil?
        log_error('Dataverse not found.', {dataverse: @dataverse_url, id: params[:id]})
        flash[:alert] = t(".dataverse_not_found", dataverse_url: @dataverse_url, id: params[:id])
        redirect_to root_path
        return
      end
    rescue Dataverse::CollectionService::UnauthorizedException => e
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