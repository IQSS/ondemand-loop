# frozen_string_literal: true

module YamlStorageCommon
  extend ActiveSupport::Concern

  class_methods do
    def load_from_file(file_path)
      return nil unless File.exist?(file_path)

      YAML.safe_load(File.read(file_path), aliases: true)
    rescue => e
      LoggingCommon.log_error("Cannot load YAML file", { file: file_path }, e)
      nil
    end
  end

  def to_yaml
    raise NotImplementedError, 'Classes must implement this method when using YamlStorage'
  end

  def store_to_file(file_path)
    ensure_storage_directory!(file_path)
    File.open(file_path, "w") { |f| f.write(to_yaml) }
    true
  rescue => e
    LoggingCommon.log_error("Cannot store YAML file", { file: file_path }, e)
    false
  end

  private

  def ensure_storage_directory!(file_path)
    FileUtils.mkdir_p(File.dirname(file_path))
  end
end
