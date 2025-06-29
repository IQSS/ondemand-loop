require "test_helper"

class UserSettingsTest < ActiveSupport::TestCase
  test "reads and updates settings file" do
    Dir.mktmpdir do |dir|
      path = Pathname.new(File.join(dir, "settings.yml"))
      settings = UserSettings.new(path: path)
      assert_equal({}, settings.user_settings.to_h)

      settings.update_user_settings({active_project: "123"})
      loaded = UserSettings.new(path: path)
      assert_equal "123", loaded.user_settings.active_project
    end
  end
end
