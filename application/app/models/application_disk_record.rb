class ApplicationDiskRecord

  def self.metadata_root_directory
    Configuration.metadata_root
  end

  def self.generate_id
    SecureRandom.uuid.to_s
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
end