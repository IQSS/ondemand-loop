module ApplicationHelper

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end

  def files_app_url(dir)
    File.join(Configuration.files_app_path, dir)
  end

  def nav_link_to(name, path, **options)
    options[:aria] ||= {}
    if current_page?(path)
      options[:aria][:current] = 'page'
      existing_classes = options[:class].to_s.split
      options[:class] = (existing_classes << 'active').uniq.join(' ')
    end
    link_to(name, path, **options)
  end

  def alert_class(type)
    class_type = {error: 'danger', warning: 'warning', info: 'info'}.fetch(type.to_sym, 'info')
    "alert alert-#{class_type}"
  end
end
