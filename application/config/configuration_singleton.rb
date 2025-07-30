require 'dotenv'
require_relative 'configuration_property'
class ConfigurationSingleton

  def initialize
    load_dotenv_files
    add_property_configs
  end

  def property_configs
    [
      ::ConfigurationProperty.file_content(:version, default: File.join(app_root, 'VERSION').to_s),
      ::ConfigurationProperty.file_content(:ood_version, default: '/opt/ood/VERSION', read_from_env: true, env_names: ['OOD_VERSION', 'ONDEMAND_VERSION']),
      ::ConfigurationProperty.path(:metadata_root, default: File.join(Dir.home, '.loop_metadata')),
      ::ConfigurationProperty.path(:download_root, default: File.join(Dir.home, 'loop_downloads')),
      ::ConfigurationProperty.property(:ruby_binary, default: File.join(RbConfig::CONFIG['bindir'], 'ruby')),
      ::ConfigurationProperty.property(:files_app_path, default: '/pun/sys/dashboard/files/fs'),
      ::ConfigurationProperty.property(:ood_dashboard_path, default: '/pun/sys/dashboard'),
      ::ConfigurationProperty.property(:connector_status_poll_interval, default: '5000'),
      ::ConfigurationProperty.property(:locale, default: :en),
      ::ConfigurationProperty.integer(:download_files_retention_period, default: 24 * 60 * 60),
      ::ConfigurationProperty.integer(:upload_files_retention_period, default: 24 * 60 * 60),
      ::ConfigurationProperty.integer(:ui_feedback_delay, default: 1500),
      ::ConfigurationProperty.integer(:detached_controller_interval, default: 10),
      ::ConfigurationProperty.integer(:detached_process_status_interval, default: 10 * 1000), # 10s in MILLISECONDS
      ::ConfigurationProperty.integer(:max_download_file_size, default: 10 * 1024 * 1024 * 1024), # 10 GIGABYTE
      ::ConfigurationProperty.integer(:max_upload_file_size, default: 1024 * 1024 * 1024), # 1 GIGABYTE
      ::ConfigurationProperty.boolean(:zenodo_enabled, default: false),
      ::ConfigurationProperty.property(:guide_url, default: 'https://iqss.github.io/ondemand-loop/'),
      ::ConfigurationProperty.property(:http_proxy, read_from_env: false),
      ::ConfigurationProperty.integer(:default_connect_timeout, default: 5),
      ::ConfigurationProperty.integer(:default_read_timeout, default: 15),
    ].freeze
  end

  def detached_process_lock_file
    ENV['OOD_LOOP_DETACHED_PROCESS_FILE'] || File.join(metadata_root, 'detached.process.lock')
  end

  def command_server_socket_file
    ENV['OOD_LOOP_COMMAND_SERVER_FILE'] || File.join(metadata_root, 'command.server.sock')
  end

  def repo_db_file
    File.join(metadata_root, 'repos', 'repo_db.yml')
  end

  def config
    @config ||= read_config
  end

  def connector_config(connector_type)
    config.fetch(connector_type.to_sym, {})
  end

  def rails_env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

  private

  def load_dotenv_files
    env_files = [
      app_root.join('.env'),
      app_root.join(".env.#{rails_env}")
    ].compact

    # overwrite = true => environment specific properties take precedence
    Dotenv.load(*env_files, overwrite: true)
  end

  def app_root
    Pathname.new(File.expand_path('../../',  __FILE__))
  end

  def config_directory
    Pathname.new(ENV['OOD_LOOP_CONFIG_DIRECTORY'] || '/etc/loop/config/loop.d')
  end

  def read_config
    files = Pathname.glob(config_directory.join('*.{yml,yaml,yml.erb,yaml.erb}'))
    files.sort.each_with_object({}) do |f, conf|
      begin
        content = ERB.new(f.read, trim_mode: '-').result(binding)
        yml = YAML.safe_load(content, aliases: true) || {}
        conf.deep_merge!(yml.deep_symbolize_keys)
      rescue => e
        Rails.logger.error("Can't read or parse #{f} because of error #{e}")
      end
    end
  end

  # Dynamically adds methods to this class based on the property_configs defined.
  # The name of the method is the name of the property.
  # The value is based on ENV and config objects, depending on the configuration of the property.
  def add_property_configs
    property_configs.each do |property|
      define_singleton_method(property.name) do
        if property.read_from_environment
          environment_value = property.map_string(property.environment_names.map do |key|
            ENV[key]
          end.compact.first)
        end
        environment_value.nil? ? config.fetch(property.name, property.default) : environment_value
      end
    end
  end
end
