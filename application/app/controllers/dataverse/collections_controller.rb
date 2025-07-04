class Dataverse::CollectionsController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  before_action :get_dv_full_hostname
  before_action :validate_dataverse_url
  before_action :init_service

  def show
    collection_id = params[:id]
    begin
      @page = params[:page] ? params[:page].to_i : 1
      @search_query = params[:query].present? ? ActionView::Base.full_sanitizer.sanitize(params[:query]) : nil
      @collection = @service.find_collection_by_id(collection_id)
      @search_result = @service.search_collection_items(collection_id, page: @page, query: @search_query)
      if @collection.nil? || @search_result.nil?
        log_error('Dataverse collection not found.', {dataverse: @dataverse_url, id: collection_id})
        flash[:alert] = t("dataverse.collections.show.dataverse_not_found", dataverse_url: @dataverse_url, id: collection_id)
        redirect_to root_path
        return
      end
    rescue Dataverse::CollectionService::UnauthorizedException => e
      log_error('Dataverse requires authorization', {dataverse: @dataverse_url, id: collection_id}, e)
      flash[:alert] = t("dataverse.collections.show.dataverse_requires_authorization", dataverse_url: @dataverse_url, id: collection_id)
      redirect_to root_path
    rescue Exception => e
      log_error('Dataverse service error', {dataverse: @dataverse_url, id: collection_id}, e)
      flash[:alert] = t("dataverse.collections.show.dataverse_service_error", dataverse_url: @dataverse_url, id: collection_id)
      redirect_to root_path
    end
  end

  private

  def get_dv_full_hostname
    @dataverse_url = current_dataverse_url
  end

  def validate_dataverse_url
    resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = resolver.resolve(@dataverse_url)
    unless result.type == ConnectorType::DATAVERSE
      redirect_to root_path, alert: t('dataverse.collections.url_not_supported', dataverse_url: @dataverse_url)
      return
    end
  end

  def init_service
    @service = Dataverse::CollectionService.new(@dataverse_url)
  end
end