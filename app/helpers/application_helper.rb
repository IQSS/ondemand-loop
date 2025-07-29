module ApplicationHelper
  include DateTimeCommon

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end

  def server_hostname
    Socket.gethostname
  end

  def guide_url
    Configuration.guide_url
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

  def status_badge(status, title: nil, filename: nil)
    # Determine the color of the badge based on the status
    case status
    when FileStatus::SUCCESS
      color = 'bg-success'
    when FileStatus::ERROR
      color = 'bg-danger'
    when FileStatus::UPLOADING
      color = 'bg-info'
    when FileStatus::DOWNLOADING
      color = 'bg-info'
    else
      color = 'bg-secondary'
    end
    aria_label = t("badge.status.a11y.text", filename: filename)
    # Return a span with the appropriate class and status text
    content_tag(:span, t("status.#{status}"), class: "badge file-status #{color}", title: title, role: 'status', "aria-label" => aria_label)
  end

end
