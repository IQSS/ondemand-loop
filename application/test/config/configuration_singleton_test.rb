# frozen_string_literal: true

require 'test_helper'

class ConfigurationSingletonTest < ActiveSupport::TestCase
  def setup
    @config_instance = ConfigurationSingleton.new
  end

  test 'should return default string config values when ENV is not set' do
    ENV.delete('OOD_LOOP_METADATA_ROOT')
    ENV.delete('OOD_LOOP_DOWNLOAD_ROOT')
    ENV.delete('OOD_LOOP_RUBY_BINARY')
    ENV.delete('OOD_LOOP_FILES_APP_PATH')
    ENV.delete('OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL')

    assert_equal File.join(Dir.home, '.downloads-for-ondemand'), @config_instance.metadata_root
    assert_equal File.join(Dir.home, 'downloads-ondemand'), @config_instance.download_root
    assert_equal File.join(RbConfig::CONFIG['bindir'], 'ruby'), @config_instance.ruby_binary
    assert_equal '/pun/sys/dashboard/files/fs', @config_instance.files_app_path
    assert_equal '5000', @config_instance.connector_status_poll_interval
  end

  test 'should return overridden string config values from ENV' do
    ENV['OOD_LOOP_METADATA_ROOT'] = '/custom/meta'
    ENV['OOD_LOOP_DOWNLOAD_ROOT'] = '/custom/download'
    ENV['OOD_LOOP_RUBY_BINARY'] = '/custom/ruby'
    ENV['OOD_LOOP_FILES_APP_PATH'] = '/custom/files'
    ENV['OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL'] = '99999'

    config = ConfigurationSingleton.new

    assert_equal Pathname.new('/custom/meta'), config.metadata_root
    assert_equal Pathname.new('/custom/download'), config.download_root
    assert_equal '/custom/ruby', config.ruby_binary
    assert_equal '/custom/files', config.files_app_path
    assert_equal '99999', config.connector_status_poll_interval
  ensure
    ENV.delete('OOD_LOOP_METADATA_ROOT')
    ENV.delete('OOD_LOOP_DOWNLOAD_ROOT')
    ENV.delete('OOD_LOOP_RUBY_BINARY')
    ENV.delete('OOD_LOOP_FILES_APP_PATH')
    ENV.delete('OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL')
  end

  test 'rails_env should fall back to development if no ENV vars are set' do
    ENV.delete('RAILS_ENV')
    ENV.delete('RACK_ENV')

    assert_equal 'development', @config_instance.rails_env
  end

  test 'rails_env should respect RAILS_ENV when set' do
    ENV['RAILS_ENV'] = 'production'
    assert_equal 'production', @config_instance.rails_env
  ensure
    ENV.delete('RAILS_ENV')
  end

  test 'rails_env should respect RACK_ENV if RAILS_ENV is not set' do
    ENV.delete('RAILS_ENV')
    ENV['RACK_ENV'] = 'staging'

    assert_equal 'staging', @config_instance.rails_env
  ensure
    ENV.delete('RACK_ENV')
  end
end
