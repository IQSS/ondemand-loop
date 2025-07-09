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

    assert_equal Pathname.new(File.join(Dir.home, '.downloads-for-ondemand')), @config_instance.metadata_root
    assert_equal Pathname.new(File.join(Dir.home, 'downloads-ondemand')), @config_instance.download_root
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

  test 'should return default integer values when ENV is not set' do
    assert_equal 24 * 60 * 60, @config_instance.download_files_retention_period
    assert_equal 24 * 60 * 60, @config_instance.upload_files_retention_period
    assert_equal 1500, @config_instance.ui_feedback_delay
    assert_equal 10, @config_instance.detached_controller_interval
    assert_equal 10_000, @config_instance.detached_process_status_interval
    assert_equal 10 * 1024 * 1024 * 1024, @config_instance.max_download_file_size
    assert_equal 1024 * 1024 * 1024, @config_instance.max_upload_file_size
  end

  test 'should override integer values from ENV' do
    ENV['OOD_LOOP_UI_FEEDBACK_DELAY'] = '3000'
    ENV['OOD_LOOP_MAX_UPLOAD_FILE_SIZE'] = '2048'

    config = ConfigurationSingleton.new
    assert_equal 3000, config.ui_feedback_delay
    assert_equal 2048, config.max_upload_file_size
  ensure
    ENV.delete('OOD_LOOP_UI_FEEDBACK_DELAY')
    ENV.delete('OOD_LOOP_MAX_UPLOAD_FILE_SIZE')
  end

  test 'should return default boolean values when ENV is not set' do
    assert_equal false, @config_instance.zenodo_enabled
  end

  test 'should override boolean values from ENV' do
    ENV['OOD_LOOP_ZENODO_ENABLED'] = 'true'
    config = ConfigurationSingleton.new
    assert_equal true, config.zenodo_enabled
  ensure
    ENV.delete('OOD_LOOP_ZENODO_ENABLED')
  end

  test 'should return default guide_url when not set' do
    assert_equal 'https://iqss.github.io/ondemand-loop/', @config_instance.guide_url
  end

  test 'should override guide_url from ENV' do
    ENV['OOD_LOOP_GUIDE_URL'] = 'https://custom.guide'
    config = ConfigurationSingleton.new
    assert_equal 'https://custom.guide', config.guide_url
  ensure
    ENV.delete('OOD_LOOP_GUIDE_URL')
  end

  test 'should correctly build detached_process_lock_file path with and without ENV' do
    default_path = File.join(@config_instance.metadata_root, 'detached.process.lock')
    assert_equal default_path, @config_instance.detached_process_lock_file

    ENV['OOD_LOOP_DETACHED_PROCESS_FILE'] = '/tmp/custom.lock'
    assert_equal '/tmp/custom.lock', ConfigurationSingleton.new.detached_process_lock_file
  ensure
    ENV.delete('OOD_LOOP_DETACHED_PROCESS_FILE')
  end

  test 'should correctly build command_server_socket_file path with and without ENV' do
    default_path = File.join(@config_instance.metadata_root, 'command.server.sock')
    assert_equal default_path, @config_instance.command_server_socket_file

    ENV['OOD_LOOP_COMMAND_SERVER_FILE'] = '/tmp/custom.sock'
    assert_equal '/tmp/custom.sock', ConfigurationSingleton.new.command_server_socket_file
  ensure
    ENV.delete('OOD_LOOP_COMMAND_SERVER_FILE')
  end

  test 'should return path to repo_db_file based on metadata_root' do
    expected = File.join(@config_instance.metadata_root, 'repos', 'repo_db.yml')
    assert_equal expected, @config_instance.repo_db_file
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

  test 'version should read VERSION file content from Rails.root' do
    config = ConfigurationSingleton.new
    assert_match /^\d+\.\d+\.\d+\+\d{4}-\d{2}-\d{2}$/, config.version
  end
end
