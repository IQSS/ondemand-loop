require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "settings attribute persists" do
    settings = OpenStruct.new(active_project: "abc")
    Current.settings = settings
    assert_equal settings, Current.settings
    assert_equal "abc", Current.settings.active_project
  end
end
