require "test_helper"
require "i18n/tasks"

# i18n task config: application/config/i18n-tasks.yml
class I18nTest < ActiveSupport::TestCase
  def setup
    @i18n = I18n::Tasks::BaseTask.new
  end

  test 'test missing translation keys' do
    missing_keys = @i18n.missing_keys
    assert_empty missing_keys, "Missing #{missing_keys.leaves.count} i18n keys, run `bundle exec i18n-tasks missing' to show them"
  end

  test 'test unused translation keys' do
    unused_keys = @i18n.unused_keys
    assert_empty unused_keys,"#{unused_keys.leaves.count} unused i18n keys, run `bundle exec i18n-tasks unused' to show them"
  end

  test 'test inconsistent interpolation' do
    inconsistent_interpolations = @i18n.inconsistent_interpolations
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
      "Please run `bundle exec i18n-tasks check-consistent-interpolations' to show them"
    assert_empty inconsistent_interpolations, error_message
  end
end