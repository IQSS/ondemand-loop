class ApplicationDiskRecord

  def self.metadata_root_directory
    Configuration.metadata_root
  end

  def self.generate_id
    SecureRandom.uuid.to_s
  end
end