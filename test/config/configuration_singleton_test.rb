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

    assert_equal Pathname.new(File.join(Dir.home, '.loop_metadata')), @config_instance.metadata_root
    assert_equal Pathname.new(File.join(Dir.home, 'loop_downloads')), @config_instance.download_root
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

  test 'should return path to repo_history_file based on metadata_root' do
    expected = File.join(@config_instance.metadata_root, 'repos', 'repo_history.yml')
    assert_equal expected, @config_instance.repo_history_file
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

  test 'ood_version defaults to nil when no env variables and file missing' do
    ENV.delete('OOD_VERSION')
    ENV.delete('ONDEMAND_VERSION')
    assert_nil ConfigurationSingleton.new.ood_version
  end

  test 'ood_version reads path from OOD_VERSION env variable' do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'ver')
      File.write(f, '2.0.0')
      ENV['OOD_VERSION'] = f
      assert_equal '2.0.0', ConfigurationSingleton.new.ood_version
    ensure
      ENV.delete('OOD_VERSION')
    end
  end

  test 'ood_version falls back to ONDEMAND_VERSION if OOD_VERSION not set' do
    Dir.mktmpdir do |dir|
      f = File.join(dir, 'ver')
      File.write(f, '3.0.0')
      ENV.delete('OOD_VERSION')
      ENV['ONDEMAND_VERSION'] = f
      assert_equal '3.0.0', ConfigurationSingleton.new.ood_version
    ensure
      ENV.delete('ONDEMAND_VERSION')
    end
  end

  test 'OOD_VERSION env takes precedence over ONDEMAND_VERSION' do
    Dir.mktmpdir do |dir|
      f1 = File.join(dir, 'ver1')
      f2 = File.join(dir, 'ver2')
      File.write(f1, 'a')
      File.write(f2, 'b')
      ENV['OOD_VERSION'] = f1
      ENV['ONDEMAND_VERSION'] = f2
      assert_equal 'a', ConfigurationSingleton.new.ood_version
    ensure
      ENV.delete('OOD_VERSION')
      ENV.delete('ONDEMAND_VERSION')
    end
  end

  test 'loads configuration from OOD_LOOP_CONFIG_DIRECTORY' do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'foo.yml'), { dataverse: { restrictions: 'some_value' } }.deep_stringify_keys.to_yaml)
      ENV['OOD_LOOP_CONFIG_DIRECTORY'] = dir
      config = ConfigurationSingleton.new
      assert_equal 'some_value', config.connector_config(:dataverse)[:restrictions]
    ensure
      ENV.delete('OOD_LOOP_CONFIG_DIRECTORY')
    end
  end

  test 'config memoizes result on subsequent calls' do
    config = ConfigurationSingleton.new
    
    # Mock read_config to verify it's only called once due to memoization
    config.expects(:read_config).once.returns({ test: 'value' })
    
    # Clear existing config to ensure fresh test
    config.instance_variable_set(:@config, nil)
    
    first_call = config.config
    second_call = config.config
    
    assert_same first_call, second_call
  end

  test 'dataverse_hub memoizes and logs creation' do
    hub = mock('hub')
    Dataverse::DataverseHub.expects(:new).once.returns(hub)

    config = ConfigurationSingleton.new
    assert_same hub, config.dataverse_hub
    assert_same hub, config.dataverse_hub
  end

  test 'repo_db memoizes and logs creation' do
    db = mock('repo_db')
    Repo::RepoDb.expects(:new).with(db_path: @config_instance.repo_db_file).once.returns(db)
    db.stubs(:size).returns(3)
    db.stubs(:db_path).returns(@config_instance.repo_db_file)

    config = ConfigurationSingleton.new
    assert_same db, config.repo_db
    assert_same db, config.repo_db
  end

  test 'repo_history memoizes and logs creation' do
    history = mock('repo_history')
    Repo::RepoHistory.expects(:new).with(db_path: @config_instance.repo_history_file).once.returns(history)
    history.stubs(:size).returns(4)
    history.stubs(:db_path).returns(@config_instance.repo_history_file)

    config = ConfigurationSingleton.new
    assert_same history, config.repo_history
    assert_same history, config.repo_history
  end

  test 'repo_resolver_service memoizes and logs creation' do
    service = mock('resolver_service')
    Repo::RepoResolverService.expects(:build).once.returns(service)

    config = ConfigurationSingleton.new
    assert_same service, config.repo_resolver_service
    assert_same service, config.repo_resolver_service
  end

  test 'navigation returns array of Nav::MainItem objects' do
    config = ConfigurationSingleton.new
    navigation = config.navigation

    assert_instance_of Array, navigation
    assert navigation.all? { |item| item.is_a?(Nav::MainItem) }
    assert navigation.size > 0
  end

  test 'navigation memoizes result on subsequent calls' do
    config = ConfigurationSingleton.new
    
    # Clear any existing navigation instance variable to ensure fresh test
    config.instance_variable_set(:@navigation, nil)
    config.expects(:config).once.returns({})
    
    # Mock the building process to verify it's only called once due to memoization
    Nav::NavDefaults.expects(:navigation_items).once.returns([])
    Nav::NavBuilder.expects(:build).once.returns([])
    
    first_call = config.navigation
    second_call = config.navigation
    
    assert_same first_call, second_call
  end

  test 'navigation includes expected default navigation items' do
    config = ConfigurationSingleton.new
    navigation = config.navigation

    # Check for key navigation items by their IDs
    nav_ids = navigation.map(&:id)
    assert_includes nav_ids, 'nav-projects'
    assert_includes nav_ids, 'nav-downloads' 
    assert_includes nav_ids, 'nav-uploads'
    assert_includes nav_ids, 'repositories'
    assert_includes nav_ids, 'nav-ood-dashboard'
    assert_includes nav_ids, 'help'
  end

  test 'navigation respects configuration overrides when present' do
    # Create a temporary config that has navigation overrides
    temp_config = { navigation: [{ id: 'nav-projects', label: 'Custom Projects Label' }] }
    config = ConfigurationSingleton.new
    config.stubs(:config).returns(temp_config)
    navigation = config.navigation
    
    projects_item = navigation.find { |item| item.id == 'nav-projects' }
    assert_not_nil projects_item
    assert_equal 'Custom Projects Label', projects_item.label
  end

  test 'should return default timeout and pagination values when ENV is not set' do
    assert_equal 5, @config_instance.default_connect_timeout
    assert_equal 15, @config_instance.default_read_timeout
    assert_equal 20, @config_instance.default_pagination_items
  end

  test 'should override timeout and pagination values from ENV' do
    ENV['OOD_LOOP_DEFAULT_CONNECT_TIMEOUT'] = '10'
    ENV['OOD_LOOP_DEFAULT_READ_TIMEOUT'] = '30'
    ENV['OOD_LOOP_DEFAULT_PAGINATION_ITEMS'] = '50'

    config = ConfigurationSingleton.new
    assert_equal 10, config.default_connect_timeout
    assert_equal 30, config.default_read_timeout
    assert_equal 50, config.default_pagination_items
  ensure
    ENV.delete('OOD_LOOP_DEFAULT_CONNECT_TIMEOUT')
    ENV.delete('OOD_LOOP_DEFAULT_READ_TIMEOUT')
    ENV.delete('OOD_LOOP_DEFAULT_PAGINATION_ITEMS')
  end

  test 'should return default dataverse_hub_url and zenodo_default_url when ENV is not set' do
    assert_equal 'https://hub.dataverse.org/api/installations', @config_instance.dataverse_hub_url
    assert_equal 'https://zenodo.org', @config_instance.zenodo_default_url
  end

  test 'should override dataverse_hub_url and zenodo_default_url from ENV' do
    ENV['OOD_LOOP_DATAVERSE_HUB_URL'] = 'https://custom.dataverse'
    ENV['OOD_LOOP_ZENODO_DEFAULT_URL'] = 'https://custom.zenodo'

    config = ConfigurationSingleton.new
    assert_equal 'https://custom.dataverse', config.dataverse_hub_url
    assert_equal 'https://custom.zenodo', config.zenodo_default_url
  ensure
    ENV.delete('OOD_LOOP_DATAVERSE_HUB_URL')
    ENV.delete('OOD_LOOP_ZENODO_DEFAULT_URL')
  end

  test 'logging_root_path returns default path when logging_root is nil' do
    @config_instance.stubs(:logging_root).returns(nil)
    expected_path = File.join(@config_instance.metadata_root, 'logs')

    # Mock FileUtils to avoid actual directory creation in tests
    FileUtils.stubs(:mkdir_p)

    assert_equal expected_path, @config_instance.logging_root_path
  end

  test 'logging_root_path returns custom path when logging_root is set' do
    custom_root = '/custom/logging'

    # Mock the global Configuration singleton that's called in the method
    ::Configuration.stubs(:logging_root).returns(custom_root)
    @config_instance.stubs(:logging_root).returns(custom_root)

    # Mock system calls - need to stub Process.euid as well
    Process.stubs(:euid).returns(1000)
    Etc.stubs(:getpwuid).with(1000).returns(OpenStruct.new(name: 'testuser'))
    FileUtils.stubs(:mkdir_p)

    # Clear memoized value to ensure fresh test
    @config_instance.instance_variable_set(:@logging_root_path, nil)

    expected_path = File.join(custom_root, 'testuser')
    assert_equal expected_path, @config_instance.logging_root_path
  end

  test 'logging_root_path creates directory with correct permissions' do
    @config_instance.stubs(:logging_root).returns(nil)
    expected_path = File.join(@config_instance.metadata_root, 'logs')

    # Verify mkdir_p is called with mode 0o700
    FileUtils.expects(:mkdir_p).with(expected_path, mode: 0o700)

    @config_instance.logging_root_path
  end

  test 'logging_root_path memoizes result on subsequent calls' do
    @config_instance.stubs(:logging_root).returns(nil)
    FileUtils.stubs(:mkdir_p)

    # Clear memoized value to ensure fresh test
    @config_instance.instance_variable_set(:@logging_root_path, nil)

    first_call = @config_instance.logging_root_path
    second_call = @config_instance.logging_root_path

    assert_same first_call, second_call
  end

  test 'logging_root_path handles missing user gracefully' do
    custom_root = '/custom/logging'
    @config_instance.stubs(:logging_root).returns(custom_root)
    ::Configuration.stubs(:logging_root).returns(custom_root)

    # Mock Etc.getpwuid to return struct without name property
    Process.stubs(:euid).returns(1000)
    Etc.stubs(:getpwuid).with(1000).returns(OpenStruct.new(name: nil))
    ENV.delete('USER')
    ENV.delete('USERNAME')
    FileUtils.stubs(:mkdir_p)

    # Clear memoized value to ensure fresh test
    @config_instance.instance_variable_set(:@logging_root_path, nil)

    expected_path = File.join(custom_root, 'unknown')
    assert_equal expected_path, @config_instance.logging_root_path
  end

  test 'logging_root_path works with ENV fallback when getpwuid name is nil' do
    custom_root = '/custom/logging'
    @config_instance.stubs(:logging_root).returns(custom_root)
    ::Configuration.stubs(:logging_root).returns(custom_root)

    # Mock getpwuid to return a struct with nil name, so it falls back to ENV
    Process.stubs(:euid).returns(1000)
    Etc.stubs(:getpwuid).with(1000).returns(OpenStruct.new(name: nil))
    ENV['USER'] = 'envuser'
    FileUtils.stubs(:mkdir_p)

    # Clear memoized value to ensure fresh test
    @config_instance.instance_variable_set(:@logging_root_path, nil)

    expected_path = File.join(custom_root, 'envuser')
    assert_equal expected_path, @config_instance.logging_root_path
  ensure
    ENV.delete('USER')
  end

  test 'logging_root_path falls back to USERNAME when USER is not set' do
    custom_root = '/custom/logging'
    @config_instance.stubs(:logging_root).returns(custom_root)
    ::Configuration.stubs(:logging_root).returns(custom_root)

    # Mock getpwuid to return nil name, and no USER env, but USERNAME is set
    Process.stubs(:euid).returns(1000)
    Etc.stubs(:getpwuid).with(1000).returns(OpenStruct.new(name: nil))
    ENV.delete('USER')
    ENV['USERNAME'] = 'winuser'
    FileUtils.stubs(:mkdir_p)

    # Clear memoized value to ensure fresh test
    @config_instance.instance_variable_set(:@logging_root_path, nil)

    expected_path = File.join(custom_root, 'winuser')
    assert_equal expected_path, @config_instance.logging_root_path
  ensure
    ENV.delete('USERNAME')
  end

  test 'should return nil for http_proxy when not set' do
    assert_nil @config_instance.http_proxy
  end

  test 'should return nil for logging_root when not set' do
    assert_nil @config_instance.logging_root
  end

  test 'should return default locale as symbol' do
    assert_equal :en, @config_instance.locale
  end

  test 'should override locale from ENV' do
    ENV['OOD_LOOP_LOCALE'] = 'es'
    config = ConfigurationSingleton.new
    assert_equal 'es', config.locale
  ensure
    ENV.delete('OOD_LOOP_LOCALE')
  end

  test 'should return default ood_dashboard_path when ENV is not set' do
    assert_equal '/pun/sys/dashboard', @config_instance.ood_dashboard_path
  end

  test 'should override ood_dashboard_path from ENV' do
    ENV['OOD_LOOP_OOD_DASHBOARD_PATH'] = '/custom/dashboard'
    config = ConfigurationSingleton.new
    assert_equal '/custom/dashboard', config.ood_dashboard_path
  ensure
    ENV.delete('OOD_LOOP_OOD_DASHBOARD_PATH')
  end
end
