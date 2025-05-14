# frozen_string_literal: true

# Class to dynamically load connector classes.
# This is to avoid creating a factory/strategy class for every connector specific class required
class ConnectorClassDispatcher

  def self.file_connector_status(download_file)
    self.load(download_file.type, 'ConnectorStatus', download_file)
  end

  def self.upload_file_connector_status(upload_file)
    self.load(upload_file.type, 'UploadConnectorStatus', upload_file)
  end

  def self.connector_metadata(download_file)
    self.load(download_file.type, 'ConnectorMetadata', download_file)
  end

  def self.upload_connector_metadata(upload_file)
    self.load(upload_file.type, 'UploadConnectorMetadata', upload_file)
  end

  def self.download_processor(download_file)
    self.load(download_file.type, 'ConnectorDownloadProcessor', download_file)
  end

  def self.upload_processor(upload_file)
    self.load(upload_file.type, 'ConnectorUploadProcessor', upload_file)
  end

  private

  def self.load(module_name, class_name, object)
    connector_class = "#{module_name.to_s.camelize}::#{class_name}"
    connector_class.constantize.new(object)  # Dynamically instantiate the correct class
  rescue NameError
    raise ConnectorNotSupported, "Invalid connector type #{module_name}. Class not found: #{connector_class}"
  end

  class ConnectorNotSupported < StandardError; end

end
