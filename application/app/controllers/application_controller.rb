class ApplicationController < ActionController::Base
  include RedirectBackWithAnchor

  before_action :load_user_settings
  before_action :set_dynamic_user_settings

  def ajax_request?
    request.xhr? || request.headers['X-Requested-With'] == 'XMLHttpRequest'
  end

  private

  def load_user_settings
    Current.settings = UserSettings.new
  end

  def set_dynamic_user_settings
    new_values = {}
    UserSettings::DYNAMIC_ATTRIBUTES.each do |key|
      value = request.request_parameters[key] || params[key]
      next if value.nil?

      new_values[key] = value
    end

    return if new_values.empty?
    Current.settings.update_user_settings(new_values)
  end
end
