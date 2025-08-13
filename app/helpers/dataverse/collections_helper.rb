module Dataverse::CollectionsHelper

  def link_to_dataverse_collection(body, repo_url, identifier, html_options = {})
    repo_url_obj = repo_url.is_a?(Repo::RepoUrl) ? repo_url : Repo::RepoUrl.parse(repo_url)
    link = link_to_explore(ConnectorType::DATAVERSE, repo_url_obj, type: 'collections', id: identifier)
    link_to(body, link, html_options)
  end

  def link_to_root_dataverse_collection(repo_url, html_options = {})
    repo_url_obj = repo_url.is_a?(Repo::RepoUrl) ? repo_url : Repo::RepoUrl.parse(repo_url)
    link_to_dataverse_collection(repo_url_obj.server_url, repo_url_obj, ':root', html_options)
  end

  def link_to_dataset(body, dataverse_url, persistent_id, html_options = {})
    repo_url = dataverse_url.is_a?(Repo::RepoUrl) ? dataverse_url : Repo::RepoUrl.parse(dataverse_url)
    link = link_to_explore(ConnectorType::DATAVERSE, repo_url, type: 'datasets', id: persistent_id)
    link_to(body, link, html_options)
  end

  def external_collection_url(dataverse_url, identifier)
    FluentUrl.new(dataverse_url).add_path('dataverse').add_path(identifier).to_s
  end

  def search_results_count(search_result)
    return I18n.t('acts_as_page.out_of_range') if search_result.data.out_of_range?
    first = search_result.data.start + 1
    last = [search_result.data.start + search_result.data.per_page, search_result.data.total_count].min
    I18n.t('acts_as_page.results_summary', start_index: first, end_index: last, total_count: search_result.data.total_count)
  end

  def link_to_search_results_prev_page(repo_url, dataverse, search_result, html_options = {})
    unless search_result.data.first_page?
      params = { page: search_result.data.prev_page }
      params[:query] = search_result.data.q if search_result.data.q.present? && search_result.data.q != '*'
      url = link_to_explore(ConnectorType::DATAVERSE, repo_url,
                            type: 'collections', id: dataverse.data.alias, **params)
      html_options['aria-label'] = I18n.t('acts_as_page.link_prev_page_a11y_label')
      html_options[:title] = I18n.t('acts_as_page.link_prev_page_title')
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(url, html_options) do
        raw('<i class="bi bi-chevron-left" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t('acts_as_page.link_prev_page_a11y_label') + '</span>')
      end
    end
  end

  def link_to_search_results_next_page(repo_url, dataverse, search_result, html_options = {})
    unless search_result.data.last_page?
      params = { page: search_result.data.next_page }
      params[:query] = search_result.data.q if search_result.data.q.present? && search_result.data.q != '*'
      url = link_to_explore(ConnectorType::DATAVERSE, repo_url,
                            type: 'collections', id: dataverse.data.alias, **params)
      html_options['aria-label'] = I18n.t('acts_as_page.link_next_page_a11y_label')
      html_options[:title] = I18n.t('acts_as_page.link_next_page_title')
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(url, html_options) do
        raw('<i class="bi bi-chevron-right" aria-hidden="true"></i><span class="visually-hidden">' +
          I18n.t('acts_as_page.link_next_page_a11y_label') + '</span>')
      end
    end
  end
end
