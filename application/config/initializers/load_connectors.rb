Rails.autoloaders.main.push_dir(Rails.root.join('connectors'))

Dir.glob(Rails.root.join('connectors', '*', 'config', 'initializers', '*.rb')).sort.each do |initializer|
  require initializer
end

Rails.application.config.to_prepare do
  Dir.glob(Rails.root.join('connectors', '*', 'views')).each do |path|
    ActionController::Base.prepend_view_path(path)
  end
end
