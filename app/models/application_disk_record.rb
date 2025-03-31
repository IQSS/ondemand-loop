class ApplicationDiskRecord

  def self.metadata_root_directory
    Configuration.metadata_root
  end

  def self.generate_id
    SecureRandom.uuid.to_s
  end

  def verify(file_path, expected_md5)
    return false unless File.exist?(file_path)

    file_md5 = Digest::MD5.file(file_path).hexdigest
    file_md5 == expected_md5
  end
end