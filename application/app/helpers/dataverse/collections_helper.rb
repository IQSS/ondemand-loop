module Dataverse::CollectionsHelper

  def link_to_dataverse_collection(body, dataverse_url, identifier, html_options = {})
    url_options = {}
    url_options[:dv_port] = params[:dv_port]
    url_options[:dv_scheme] = params[:dv_scheme]
    link_to(body, view_dataverse_url(URI.parse(dataverse_url).hostname, identifier, url_options), html_options)
  end

  def link_to_root_dataverse_collection(dataverse_url, html_options = {})
    link_to_dataverse_collection(dataverse_url, dataverse_url, ':root', html_options)
  end

  def link_to_dataset(body, dataverse_url, persistent_id, html_options = {})
    url_options = {}
    url_options[:dv_port] = params[:dv_port]
    url_options[:dv_scheme] = params[:dv_scheme]
    link_to(body, view_dataverse_dataset_url(URI.parse(dataverse_url).hostname, persistent_id, url_options), html_options)
  end

  def external_collection_url(dataverse_url, identifier)
    FluentUrl.new(dataverse_url).add_path('dataverse').add_path(identifier).to_s
  end

  def search_results_count(search_result)
    return I18n.t("acts_as_page.out_of_range") if search_result.data.out_of_range?
    first = search_result.data.start + 1
    last = [search_result.data.start + search_result.data.per_page, search_result.data.total_count].min
    I18n.t("acts_as_page.results_summary", start_index: first, end_index: last, total_count: search_result.data.total_count)
  end

  def link_to_search_results_prev_page(dataverse_url, dataverse, search_result, html_options = {})
    unless search_result.data.first_page?
      uri = URI.parse(dataverse_url)
      url_options = {}
      url_options[:dv_port] = uri.port if uri.port != 443
      url_options[:dv_scheme] = uri.scheme if uri.scheme != 'https'
      url_options[:page] = search_result.data.prev_page
      url_options[:query] = search_result.data.q if search_result.data.q.present? && search_result.data.q != '*'
      html_options['aria-label'] = I18n.t("acts_as_page.link_prev_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_prev_page_title")
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(view_dataverse_url(uri.hostname, dataverse.data.alias, url_options), html_options) do
        raw('<i class="bi bi-chevron-left" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t("acts_as_page.link_prev_page_a11y_label") + '</span>')
      end
    end
  end

  def link_to_search_results_next_page(dataverse_url, dataverse, search_result, html_options = {})
    unless search_result.data.last_page?
      uri = URI.parse(dataverse_url)
      url_options = {}
      url_options[:dv_port] = uri.port if uri.port != 443
      url_options[:dv_scheme] = uri.scheme if uri.scheme != 'https'
      url_options[:page] = search_result.data.next_page
      url_options[:query] = search_result.data.q if search_result.data.q.present? && search_result.data.q != '*'
      html_options['aria-label'] = I18n.t("acts_as_page.link_next_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_next_page_title")
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(view_dataverse_url(uri.hostname, dataverse.data.alias, url_options), html_options) do
        raw('<i class="bi bi-chevron-right" aria-hidden="true"></i><span class="visually-hidden">' +
          I18n.t("acts_as_page.link_next_page_a11y_label") + '</span>')
      end
    end
  end
end