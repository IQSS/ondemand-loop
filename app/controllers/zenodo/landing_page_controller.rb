class Zenodo::LandingPageController < ApplicationController
  include LoggingCommon

  def index
    @query = params[:query]
    @page = params[:page]&.to_i || 1
    if @query.present?
      service = Zenodo::SearchService.new
      @results = service.search(@query, page: @page)
    end
  rescue => e
    log_error('Search Zenodo error', { query: @query, page: @page }, e)
    redirect_to root_path, alert: t('.message_search_error', query: @query)
  end
end
