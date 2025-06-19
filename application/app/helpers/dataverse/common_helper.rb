module Dataverse::CommonHelper
  def current_dataverse_url
    if params[:dataverse_url]
      return URI.parse(params[:dataverse_url]).to_s
    elsif params[:dv_hostname]
      hostname = params[:dv_hostname]
      scheme = params[:dv_scheme] || "https"
      port = params[:dv_port] || 443
      return URI.parse(scheme + "://" + hostname + ":" + port.to_s).to_s
    else
      flash[:alert] = I18n.t("helpers.dataverse.invalid_hostname")
      redirect_to root_path
      return nil
    end
  end
end