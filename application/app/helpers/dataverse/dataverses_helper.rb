module Dataverse::DataversesHelper

  def link_to_dataverse(body, dataverse_url, identifier, html_options = {})
    url_options = {}
    url_options[:dv_port] = params[:dv_port]
    url_options[:dv_scheme] = params[:dv_scheme]
    link_to(body, view_dataverse_url(URI.parse(dataverse_url).hostname, identifier, url_options), html_options)
  end

  def link_to_root_dataverse(dataverse_url, html_options = {})
    link_to_dataverse(dataverse_url, dataverse_url, ':root', html_options)
  end

  def link_to_dataset(body, dataverse_url, persistent_id, html_options = {})
    url_options = {}
    url_options[:dv_port] = params[:dv_port]
    url_options[:dv_scheme] = params[:dv_scheme]
    link_to(body, view_dataverse_dataset_url(URI.parse(dataverse_url).hostname, persistent_id, url_options), html_options)
  end
end