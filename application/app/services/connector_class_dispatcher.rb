# frozen_string_literal: true

# Class to dynamically load connector classes.
# This is to avoid creating a factory/strategy class for every connector specific class required
class ConnectorClassDispatcher
  def self.types
    ConnectorTypes.new
  end

  def self.file_connector_status(download_file)
    self.load(download_file.type, 'ConnectorStatus', download_file)
  end

  def self.connector_metadata(download_file)
    self.load(download_file.type, 'ConnectorMetadata', download_file)
  end

  def self.download_processor(download_file)
    self.load(download_file.type, 'ConnectorDownloadProcessor', download_file)
  end

  private

  TYPES = [:dataverse].freeze

  def self.load(module_name, class_name, object)
    connector_class = "#{module_name.to_s.camelize}::#{class_name}"
    connector_class.constantize.new(object)  # Dynamically instantiate the correct class
  rescue NameError
    raise "Unsupported class name: #{connector_class}"
  end

  class ConnectorNotSupported < StandardError; end
  class ConnectorTypes
    TYPES.each do |type|
      # Dynamically define methods based on the TYPES array
      define_method(type) do
        type.to_s
      end
    end

    # Catch calls to undefined methods
    def method_missing(method, *args, &block)
      if TYPES.include?(method)
        super
      else
        raise ConnectorNotSupported, "Invalid connector type #{method}"
      end
    end
  end
end
