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
    log_error('Zenodo search error', {}, e)
    flash[:alert] = t('.search_error')
    redirect_to root_path
  end
end
