class ApplicationDiskRecord

  def self.metadata_root_directory
    Configuration.user_downloads_for_ondemand_metadata_folder
  end

  def self.generate_id
    SecureRandom.uuid.to_s
  end
end