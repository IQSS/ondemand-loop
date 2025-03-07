class ApplicationDiskRecord
  METADATA_FOLDER = ".dataverse-for-ondemand/"

  def self.metadata_root_directory
    @root_directory ||= ENV["HOME"] + "/" + METADATA_FOLDER
  end

  def self.generate_id
    SecureRandom.uuid.to_s
  end
end