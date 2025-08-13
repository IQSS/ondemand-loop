class ApplicationController < ActionController::Base
  include RedirectBackWithAnchor

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :load_user_settings

  def ajax_request?
    request.xhr? || request.headers['X-Requested-With'] == 'XMLHttpRequest'
  end

  private

  def load_user_settings
    Current.settings = UserSettings.new
    @active_project = Project.find(Current.settings.user_settings.active_project.to_s)
  end
end
