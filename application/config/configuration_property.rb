require 'fileutils'

# A generic class to map configurations to Ruby runtime objects like Intgers, Strings
# and Booleans.
class ConfigurationProperty

  def self.boolean(name, default: nil, read_from_env: true, env_names: nil)
    ConfigurationProperty.new(name, default, read_from_env, env_names, BooleanMapper)
  end

  def self.integer(name, default: nil, read_from_env: true, env_names: nil)
    ConfigurationProperty.new(name, default, read_from_env, env_names, IntegerMapper)
  end

  def self.path(name, default: nil, read_from_env: true, env_names: nil)
    ConfigurationProperty.new(name, default, read_from_env, env_names, PathMapper)
  end

  def self.file_content(name, default: nil, read_from_env: false, env_names: nil)
    ConfigurationProperty.new(name, default, read_from_env, env_names, FileContentMapper)
  end

  def self.property(name, default: nil, read_from_env: true, env_names: nil)
    ConfigurationProperty.new(name, default, read_from_env, env_names, PassThroughMapper)
  end

  attr_reader :name, :default, :read_from_environment, :environment_names

  #
  # Represents configuration property.
  # These properties are used by the ConfigurationSingleton class to manage static properties.
  #
  # The default environment name is created based on the property name: ["LOOP_#{@name.to_s.upcase}"]
  # The different mappers are used to transform string values from the environment to a type.
  #
  # @param name [symbol] name of the property.To be used by ConfigurationSingleton to lookup a value in the config object.
  # @param default [any] default value for the property. To be used by ConfigurationSingleton when no value is defined.
  # @param read_from_env [boolean] if true, ConfigurationSingleton will use the ENV to lookup a value.
  # @param env_names [array] list of environment names to lookup a value for this property in the ENV object. It defaults to ["LOOP_#{@name.to_s.upcase}"] if nil provided
  # @param mapper [Mapper Class] Mapper to transform strings from the environment to the property type.
  #
  def initialize(name, default, read_from_env, env_names, mapper)
    @name = name.to_sym
    @mapper = mapper || PassThroughMapper
    @default = default.is_a?(String) ? @mapper.map_string(default) : default
    @read_from_environment = !!read_from_env

    environment_names = env_names || ["OOD_LOOP_#{@name.to_s.upcase}"]
    @environment_names = @read_from_environment ? environment_names : []
  end

  def map_string(value)
    @mapper.map_string(value)
  end

  class PassThroughMapper
    def self.map_string(string_value)
      string_value
    end
  end

  class PathMapper
    def self.map_string(string_value)
      return nil if string_value.nil?

      full_path = File.expand_path(string_value.to_s)
      dir = File.dirname(full_path)
      # Ensure the directory exists
      FileUtils.mkdir_p(dir)
      Pathname(full_path)
    end
  end

  class FileContentMapper
    def self.map_string(string_value)
      return nil if string_value.nil?

      version_path = Pathname.new(string_value)
      version_path.read if version_path.file?
    end
  end

  class IntegerMapper
    def self.map_string(string_value)
      string_value.nil? ? string_value : Integer(string_value.to_s)
    end
  end

  class BooleanMapper
    def self.map_string(string_value)
      string_value.nil? ? string_value : BooleanMapper.to_bool(string_value.to_s.upcase)
    end

    private
    FALSE_VALUES = ['', '0', 'F', 'FALSE', 'OFF', 'NO'].freeze
    
    def self.to_bool(value)
      !FALSE_VALUES.include?(value)
    end

  end
end