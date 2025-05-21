# frozen_string_literal: true

module ConnectorHelper

  def upload_collection_connector_bar(collection)
    "/connectors/#{collection.type.to_s}/upload_collection_bar"
  end

  def connector_icon(type)
    image_tag(type.to_s.downcase, class: 'icon-class', title: type.to_s)
  end

  def api_key_status_badge(collection)
    if collection.connector_metadata.api_key.blank?
      # Missing API key – use a softer alert red
      content_tag(:span, class: 'badge badge-soft-danger') do
        raw('<i class="bi bi-exclamation-circle me-1"></i><span class="ms-1">' + I18n.t('helpers.key_missing') + '</span>')
      end
    elsif collection.connector_metadata.verification_date.blank?
      # Provided but not yet verified – use a muted or secondary tone
      content_tag(:span, class: 'badge badge-soft-secondary text-dark') do
        raw('<i class="bi bi-question-circle me-1"></i><span class="ms-1">' + I18n.t('helpers.key_not_verified') + '</span>')
      end
    else
      # Verified – use a soft green tone
      content_tag(:span, class: 'badge badge-soft-success') do
        raw('<i class="bi bi-check-circle-fill me-1"></i><span class="ms-1">' + I18n.t('helpers.key_verified') + '</span>')
      end
    end
  end

end
