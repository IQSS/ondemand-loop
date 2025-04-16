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

  def search_results_count(search_result)
    return "0 of #{search_result.data.total_count} results" if search_result.data.out_of_range?
    first = search_result.data.start + 1
    last = [search_result.data.start + search_result.data.per_page, search_result.data.total_count].min
    "#{first} to #{last} of #{search_result.data.total_count} results"
  end

  def link_to_search_results_prev_page(dataverse_url, dataverse, search_result, html_options = {})
    unless search_result.data.first_page?
      url_options = {}
      url_options[:dv_port] = params[:dv_port]
      url_options[:dv_scheme] = params[:dv_scheme]
      url_options[:page] = search_result.data.prev_page
      link_to("<", view_dataverse_url(URI.parse(dataverse_url).hostname, dataverse.data.alias, url_options), html_options)
    end
  end

  def link_to_search_results_next_page(dataverse_url, dataverse, search_result, html_options = {})
    unless search_result.data.last_page?
      url_options = {}
      url_options[:dv_port] = params[:dv_port]
      url_options[:dv_scheme] = params[:dv_scheme]
      url_options[:page] = search_result.data.next_page
      link_to(">", view_dataverse_url(URI.parse(dataverse_url).hostname, dataverse.data.alias, url_options), html_options)
    end
  end
end