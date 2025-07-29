module Dataverse::DatasetsHelper
  def file_thumbnail(dataverse_url, file)
    if [ 'image/png', 'image/jpeg', 'image/bmp', 'image/gif' ].include? file.data_file.content_type
      src = "#{dataverse_url}/api/access/datafile/#{file.data_file.id}?imageThumb=true"
      image_tag(src, alt: file.label, title: file.label)
    else
      image_tag('file_thumbnail.png', alt: file.label, title: file.label)
    end
  end

  def verify_dataset(dataset)
    retrictions_service.validate_dataset(dataset)
  end

  def verify_file(file)
    retrictions_service.validate_dataset_file(file)
  end

  def dataverse_dataset_view_url(dataverse_url, persistent_id, version: nil, page: nil, query: nil)
    uri = URI.parse(dataverse_url)
    url_options = {}
    url_options[:dv_port] = uri.port if uri.port != 443
    url_options[:dv_scheme] = uri.scheme if uri.scheme != 'https'
    url_options[:version] = version if version.present?
    url_options[:page] = page if page.present?
    url_options[:query] = query if query.present?
    view_dataverse_dataset_path(uri.hostname, persistent_id, url_options)
  end

  def link_to_dataset_prev_page(dataverse_url, persistent_id, version, page, html_options = {})
    unless page.first_page?
      dataset_url = dataverse_dataset_view_url(dataverse_url, persistent_id, version: version, page: page.prev_page, query: page.query)
      html_options['aria-label'] = I18n.t("acts_as_page.link_prev_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_prev_page_title")
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(dataset_url, html_options) do
        raw('<i class="bi bi-chevron-left" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t("acts_as_page.link_prev_page_a11y_label") + '</span>')
      end
    end
  end

  def link_to_dataset_next_page(dataverse_url, persistent_id, version, page, html_options = {})
    unless page.last_page?
      dataset_url = dataverse_dataset_view_url(dataverse_url, persistent_id, version: version, page: page.next_page, query: page.query)
      html_options['aria-label'] = I18n.t("acts_as_page.link_next_page_a11y_label")
      html_options[:title] = I18n.t("acts_as_page.link_next_page_title")
      html_options[:class] = [html_options[:class], 'btn btn-sm btn-outline-dark'].compact.join(' ')
      link_to(dataset_url, html_options) do
        raw('<i class="bi bi-chevron-right" aria-hidden="true"></i><span class="visually-hidden">' +
              I18n.t("acts_as_page.link_next_page_a11y_label") + '</span>')
      end
    end
  end

  def storage_identifier(identifier)
    identifier.to_s.split(":", 3)[0..1].join(":") if identifier
  end

  # TODO: TO BE REFACTORED INTO DataverseUrl to avoid using PARAMS
  # SAME AS OTHER METHOD IN THIS CLASS
  def dataset_versions_url(dataverse_url, persistent_id)
      url_options = {}
      url_options[:dv_port] = params[:dv_port]
      url_options[:dv_scheme] = params[:dv_scheme]
      view_dataverse_dataset_versions_path(URI.parse(dataverse_url).hostname, persistent_id, url_options)
  end

  def external_dataset_url(dataverse_url, persistent_id, version = nil)
    url = FluentUrl.new(dataverse_url)
            .add_path('dataset.xhtml')
            .add_param('persistentId', persistent_id)
    url.add_param('version', version) if version
    url.to_s
  end

  private

  def retrictions_service
    restrictions = Configuration.connector_config(:dataverse)[:restrictions]
    @validation_service ||= Dataverse::DataverseRestrictionsService.new(dataverse_restrictions: restrictions)
  end
end
