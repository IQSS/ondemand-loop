# frozen_string_literal: true

module NavHelper
  def render_icon(icon, classes: '')
    return '' if icon.blank?

    case icon
    when /^bs:\/\/(.+)/
      # Bootstrap icon: bs://bi-gear-fill => <i class="bi bi-gear-fill"></i>
      icon_name = Regexp.last_match(1)
      content_tag(:i, '', class: "bi #{icon_name} #{classes}")
    when /^connector:\/\/(.+)/
      # Connector icon: connector://zenodo => connector_icon('zenodo')
      connector_type = Regexp.last_match(1)
      connector_icon(connector_type)
    else
      # Image path: /path/to/image.jpg => <img class="icon-class" src="/path/to/image.jpg">
      image_tag(icon, class: "icon-class #{classes}")
    end
  end
end