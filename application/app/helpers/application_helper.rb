module ApplicationHelper
  include DateTimeCommon

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end

  def files_app_url(dir)
    File.join(Configuration.files_app_path, dir)
  end

  def ood_dashboard_url
    Configuration.ood_dashboard_path
  end

  def nav_link_to(name = nil, options = nil, html_options = nil, &block)
    path = options
    overridden_options = html_options
    if block_given?
      path = name
      overridden_options = options
    end

    overridden_options[:aria] ||= {}
    if current_page?(path)
      overridden_options[:aria][:current] = 'page'
      existing_classes = overridden_options[:class].to_s.split
      overridden_options[:class] = (existing_classes << 'active').uniq.join(' ')
    end
    link_to(name, options, overridden_options, &block)
  end

  def alert_class(type)
    class_type = {error: 'danger', alert: 'danger', warning: 'warning', notice: 'success', info: 'success'}.fetch(type.to_sym, 'info')
    "alert alert-#{class_type}"
  end

  def status_badge(status, title = nil)
    # Determine the color of the badge based on the status
    case status
    when FileStatus::SUCCESS
      color = 'bg-success'
    when FileStatus::ERROR
      color = 'bg-danger'
    when FileStatus::DOWNLOADING
      color = 'bg-info'
    else
      color = 'bg-secondary'
    end

    # Return a span with the appropriate class and status text
    content_tag(:span, status.to_s, class: "badge file-status #{color}", title: title)
  end

  def connector_icon(type)
    image_tag(type.to_s.downcase, class: 'icon-class')
  end
end
