# frozen_string_literal: true

# Class to dynamically load connector classes.
# This is to avoid creating a factory/strategy class for every connector specific class required
class ConnectorClassDispatcher

  def self.file_connector_status(download_file)
    self.load(download_file.type, 'ConnectorStatus', download_file)
  end

  def self.download_processor(download_file)
    self.load(download_file.type, 'ConnectorDownloadProcessor', download_file)
  end

  private

  def self.load(module_name, class_name, object)
    connector_class = "#{module_name.camelize}::#{class_name}"
    connector_class.constantize.new(object)  # Dynamically instantiate the correct class
  rescue NameError
    raise "Unsupported class name: #{connector_class}"
  end
end
