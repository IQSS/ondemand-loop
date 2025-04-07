module ApplicationHelper

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
