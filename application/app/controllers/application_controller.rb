class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :load_user_settings

  private

  def load_user_settings
    Current.settings = UserSettings.new
  end
end
