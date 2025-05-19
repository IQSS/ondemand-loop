# frozen_string_literal: true

module YamlStorage
  extend ActiveSupport::Concern

  class_methods do
    def load_from_file(file_path)
      data = YAML.safe_load(File.read(file_path), permitted_classes: [Hash], aliases: true)
      return nil unless data.is_a?(Hash)

      new.tap do |instance|
        attributes.each do |attr|
          value = data[attr.to_s]

          case attr.to_s
          when 'type'
            instance.type = ConnectorType.get(value)
          when 'status'
            instance.status = FileStatus.get(value)
          else
            instance.public_send("#{attr}=", value)
          end
        end
      end
    rescue => e
      LoggingCommon.log_error("Cannot load YAML file", { file: file_path }, e)
      nil
    end

    def attributes
      self::ATTRIBUTES
    end
  end

  def to_h
    self.class.attributes.each_with_object({}) do |attr, hash|
      value = public_send(attr)
      case attr.to_s
      when 'type', 'status'
        hash[attr.to_s] = value.to_s
      else
        hash[attr.to_s] = value
      end
    end
  end

  def store_to_file
    raise NotImplementedError, "Model must implement #storage_file" unless respond_to?(:storage_file)

    ensure_storage_directory!
    File.open(storage_file, "w") { |f| f.write(to_h.deep_stringify_keys.to_yaml) }
    true
  rescue => e
    LoggingCommon.log_error("Cannot store YAML file", { file: storage_file }, e)
    false
  end

  private

  def ensure_storage_directory!
    FileUtils.mkdir_p(File.dirname(storage_file))
  end
end
