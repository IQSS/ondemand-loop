# frozen_string_literal: true

class Project < ApplicationDiskRecord
  include ActiveModel::Model
  include FileStatusSummary
  include LoggingCommon

  ATTRIBUTES = %w[id name download_dir creation_date].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of *ATTRIBUTES

  def self.all
    Dir.glob(File.join(metadata_directory, '*'))
       .select { |path| File.directory?(path) }
       .sort { |a, b| File.ctime(b) <=> File.ctime(a) }
       .map { |directory| load_metadata_from_directory(directory) }
       .compact
  end

  def self.find(project_id)
    return nil if project_id.blank?

    filename = filename_by_id(project_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def initialize(id: nil, name: nil, download_dir: nil)
    self.id = id || Project.generate_id
    self.name = name || self.id
    self.download_dir = download_dir || File.join(Configuration.download_root, self.id.to_s)
    self.creation_date = DateTimeCommon.now
  end

  def download_files
    @files ||=
      begin
        directory = File.join(self.class.download_files_directory(id))
        Dir.glob(File.join(directory, '*.yml'))
           .select { |f| File.file?(f) }
           .sort_by { |f| -File.ctime(f).to_f }
           .map { |f| DownloadFile.find(id, File.basename(f, ".yml")) }
           .compact
      end
  end
  alias_method :status_files, :download_files

  def upload_bundles
    @upload_bundles ||=
      begin
        Dir.glob(File.join(self.class.upload_bundles_directory(id), '*'))
           .select { |path| File.directory?(path) }
           .sort { |a, b| File.ctime(b) <=> File.ctime(a) }
           .map { |directory| UploadBundle.find(id, File.basename(directory)) }
           .compact
      end
  end

  def update(attributes = {})
    old_dir = download_dir
    new_dir = attributes[:download_dir] || attributes['download_dir']

    if new_dir && new_dir != old_dir
      if download_files.any? { |f| f.status.pending? || f.status.downloading? }
        errors.add(:download_dir, 'cannot be updated while files are pending or downloading')
        return false
      end

      unless File.directory?(new_dir) && File.writable?(new_dir)
        errors.add(:download_dir, 'must exist and be a writable directory')
        return false
      end
    end

    result = super
    Common::FileUtils.new.move_all(old_dir, download_dir) if result
    result
  end

  def save
    return false unless valid?

    FileUtils.mkdir_p(self.class.download_files_directory(id))
    FileUtils.mkdir_p(download_dir)
    store_to_file(self.class.filename_by_id(id))
  end

  def destroy
    project_path = self.class.project_metadata_dir(id)
    FileUtils.rm_rf(project_path)
  end

  def self.project_metadata_dir(id)
    File.join(metadata_directory, id)
  end

  private

  def self.metadata_directory
    File.join(metadata_root_directory, 'projects')
  end

  def self.download_files_directory(id)
    File.join(metadata_directory, id, 'download_files')
  end

  def self.upload_bundles_directory(id)
    File.join(metadata_directory, id, 'upload_bundles')
  end

  def self.filename_by_id(id)
    File.join(project_metadata_dir(id), "metadata.yml")
  end

  def self.load_metadata_from_directory(directory)
    metadata_file = File.join(directory, 'metadata.yml')
    load_from_file(metadata_file)
  end

  def self.load_from_file(filename)
    data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
    new.tap do |project|
      ATTRIBUTES.each { |attr| project.send("#{attr}=", data[attr]) }
    end
  rescue StandardError
    nil
  end

end
