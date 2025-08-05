module Zenodo
  module ExploreHelper

    def link_to_explore(repo_url, type:, id:)
      explore_path(connector_type: ConnectorType::ZENODO.to_s,
                   server_domain: repo_url.domain,
                   server_scheme: repo_url.scheme_override,
                   server_port: repo_url.port_override,
                   object_type: type,
                   object_id: id)
    end
    def link_to_explore_prev_page(query, search_result, repo_url, html_options = {})
      return if search_result.first_page?
      html_options['aria-label'] = I18n.t('acts_as_page.link_prev_page_a11y_label')
      html_options[:title] = I18n.t('acts_as_page.link_prev_page_title')
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(explore_path(connector_type: ConnectorType::ZENODO.to_s,
                           server_domain: repo_url.domain,
                           object_type: 'actions',
                           object_id: 'landing',
                           server_scheme: repo_url.scheme_override,
                           server_port: repo_url.port_override,
                           query: query,
                           page: search_result.prev_page), html_options) do
        raw('<i class="bi bi-chevron-left" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t('acts_as_page.link_prev_page_a11y_label') + '</span>')
      end
    end

    def link_to_explore_next_page(query, search_result, repo_url, html_options = {})
      return if search_result.last_page?
      html_options['aria-label'] = I18n.t('acts_as_page.link_next_page_a11y_label')
      html_options[:title] = I18n.t('acts_as_page.link_next_page_title')
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(explore_path(connector_type: ConnectorType::ZENODO.to_s,
                           server_domain: repo_url.domain,
                           object_type: 'actions',
                           object_id: 'landing',
                           server_scheme: repo_url.scheme_override,
                           server_port: repo_url.port_override,
                           query: query,
                           page: search_result.next_page), html_options) do
        raw('<i class="bi bi-chevron-right" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t('acts_as_page.link_next_page_a11y_label') + '</span>')
      end
    end
  end
end
