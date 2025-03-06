class ApplicationDiskRecord
  METADATA_FOLDER = ".dataverse-for-ondemand/"

  def metadata_root_directory
    @root_directory ||= ENV["HOME"] + "/" + METADATA_FOLDER
  end
end