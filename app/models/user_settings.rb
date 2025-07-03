class UserSettings
  include LoggingCommon

  def initialize(path: nil)
    @path = path || Configuration.metadata_root.join('user_settings.yml')
  end

  def user_settings
    @user_settings = read_user_settings if @user_settings.nil?
    OpenStruct.new(@user_settings.clone)
  end

  def update_user_settings(new_user_settings)
    # Ensure @user_settings is initialized
    user_settings
    @user_settings.deep_merge!(new_user_settings.deep_symbolize_keys)
    save_user_settings
  end

  private

  attr_reader :path

  def read_user_settings
    user_settings = {}
    return user_settings unless path.exist?

    begin
      yml = YAML.safe_load(path.read) || {}
      user_settings = yml.deep_symbolize_keys
    rescue StandardError => e
      log_error('Cannot read or parse settings file', {path: path}, e)
    end

    user_settings
  end

  def save_user_settings
    File.open(path.to_s, 'w') { |file| file.write(@user_settings.deep_stringify_keys.to_yaml) }
  end
end