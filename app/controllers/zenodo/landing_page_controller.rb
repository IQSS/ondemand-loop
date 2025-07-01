class Zenodo::LandingPageController < ApplicationController
  include LoggingCommon

  def index
    @query = params[:query]
    @page = params[:page]&.to_i || 1
    @per_page = params[:per_page]&.to_i || 10
    if @query.present?
      service = Zenodo::SearchService.new
      @results = service.search(@query, page: @page, per_page: @per_page)
    end
  rescue => e
    log_error('Search Zenodo error', { query: @query, page: @page }, e)
    redirect_to root_path, alert: t('zenodo.landing_page.index.message_search_error', query: @query)
  end
end
