class Dataverse::LandingPageController < ApplicationController
  include LoggingCommon

  def index
    begin
      hub_registry = DataverseHubRegistry.registry
      installations = hub_registry.installations
      page = params[:page] ? params[:page].to_i : 1
      @installations_page = Page.new(installations, page, 25)
    rescue Exception => e
      log_error('Dataverse Installations service error', {}, e)
      flash[:alert] = t("dataverse.landing_page.index.dataverse_installations_service_error")
      redirect_to root_path
    end
  end

end