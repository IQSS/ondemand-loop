class UserSettings
  include YamlStorageCommon
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
    store_to_file(path)
  end

  private

  attr_reader :path

  def to_yaml
    @user_settings.deep_stringify_keys.to_yaml
  end

  def read_user_settings
    return {} unless path.exist?

    yml = self.class.load_from_file(path) || {}
    yml.deep_symbolize_keys
  end
end