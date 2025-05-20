class ApplicationDiskRecord
  include YamlStorage
  include LoggingCommon

  def self.metadata_root_directory
    Configuration.metadata_root
  end

  def self.generate_id
    SecureRandom.uuid.to_s
    end

  def self.generate_code(length = 4)
    SecureRandom.alphanumeric(length)
  end

  def save
    raise NotImplementedError, "#{self.class} must implement save"
  end

  def update(attributes = {})
    attributes.each do |key, value|
      # Set each attribute manually
      send("#{key}=", value) if respond_to?("#{key}=")
    end

    save
  end

  def to_json
    to_h.to_json
  end

  def to_yaml
    to_h.to_yaml
  end

  def to_s
    to_json
  end
end