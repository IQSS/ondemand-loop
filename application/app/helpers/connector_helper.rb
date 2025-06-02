# frozen_string_literal: true

module ConnectorHelper

  def upload_batch_connector_info_bar(upload_batch)
    "/connectors/#{upload_batch.type.to_s}/upload_batch_info_bar"
  end

  def upload_batch_connector_actions_bar(upload_batch)
    "/connectors/#{upload_batch.type.to_s}/upload_batch_actions_bar"
  end

  def connector_icon(type)
    image_tag(type.to_s.downcase, class: 'icon-class', title: type.to_s)
  end

  def api_key_status_badge(provided)
    if provided
      content_tag(:span, class: 'badge badge-soft-success') do
        raw('<i class="bi bi-check-circle-fill me-1"></i><span class="ms-1">' + I18n.t('helpers.key_present') + '</span>')
      end
    else
      # Missing API key – use a softer alert red
      content_tag(:span, class: 'badge badge-soft-danger') do
        raw('<i class="bi bi-exclamation-circle me-1"></i><span class="ms-1">' + I18n.t('helpers.key_missing') + '</span>')
      end
    end
  end

end
