require 'dotenv'
class ConfigurationSingleton

  def initialize
    load_dotenv_files
    add_boolean_configs
    add_string_configs
  end

  def boolean_configs
    {}.freeze
  end

  def string_configs
    {
      :user_downloads_for_ondemand_metadata_folder => File.join(Dir.home, ".downloads-for-ondemand"),
      :dataverse_metadata_folder => "dataverse_metadatas",
      :download_collections_folder => "downloads",
    }.freeze
  end

  def config
    @config ||= read_config
  end

  def rails_env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || "development"
  end

  private

  def load_dotenv_files
    # .env.local first, so it can override OOD_APP_CONFIG_ROOT
    Dotenv.load(*dotenv_local_files)

    # load the rest of the dotenv files
    Dotenv.load(*dotenv_files)
  end

  def app_root
    Pathname.new(File.expand_path("../../",  __FILE__))
  end

  def dotenv_local_files
    [
      app_root.join(".env.#{rails_env}.local"),
      (app_root.join(".env.local") unless rails_env == "test")
    ].compact
  end

  def dotenv_files
    [
      app_root.join(".env.#{rails_env}"),
      app_root.join(".env")
    ].compact
  end

  FALSE_VALUES=[nil, false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO']

  def to_bool(value)
    !FALSE_VALUES.include?(value)
  end

  def config_directory
    Pathname.new(ENV['OOD_CONFIG_D_DIRECTORY'] || "/etc/ood/config/ondemand.d")
  end

  def read_config
    files = Pathname.glob(config_directory.join("*.{yml,yaml,yml.erb,yaml.erb}"))
    files.sort.each_with_object({}) do |f, conf|
      begin
        content = ERB.new(f.read, trim_mode: "-").result(binding)
        yml = YAML.safe_load(content, aliases: true) || {}
        conf.deep_merge!(yml.deep_symbolize_keys)
      rescue => e
        Rails.logger.error("Can't read or parse #{f} because of error #{e}")
      end
    end
  end

  def add_boolean_configs
    boolean_configs.each do |cfg_item, default|
      define_singleton_method(cfg_item.to_sym) do
        e = ENV["OOD_#{cfg_item.to_s.upcase}"]

        if e.nil?
          config.fetch(cfg_item, default)
        else
          to_bool(e.to_s)
        end
      end
    end.each do |cfg_item, _|
      define_singleton_method("#{cfg_item}?".to_sym) do
        send(cfg_item)
      end
    end
  end

  def add_string_configs
    string_configs.each do |cfg_item, default|
      define_singleton_method(cfg_item.to_sym) do
        e = ENV["OOD_#{cfg_item.to_s.upcase}"]

        e.nil? ? config.fetch(cfg_item, default) : e.to_s
      end
    end.each do |cfg_item, _|
      define_singleton_method("#{cfg_item}?".to_sym) do
        send(cfg_item).nil?
      end
    end
  end
end