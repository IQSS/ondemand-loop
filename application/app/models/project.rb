# frozen_string_literal: true

class Project < ApplicationDiskRecord
  include ActiveModel::Model
  include LoggingCommon

  ATTRIBUTES = %w[id name download_dir].freeze

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
    filename = filename_by_id(project_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def initialize(id: nil, name: nil, download_dir: nil)
    self.id = id || Project.generate_id
    self.name = name || self.id
    self.download_dir = download_dir || File.join(Configuration.download_root, self.id.to_s)
  end

  def files
    @files ||=
      begin
        directory = File.join(self.class.files_directory(id))
        Dir.glob(File.join(directory, '*.yml'))
           .select { |f| File.file?(f) }
           .sort_by { |f| File.ctime(f) }
           .map { |f| DownloadFile.find(id, File.basename(f, ".yml")) }
           .compact
      end
  end

  def count
    counts = files.group_by{|f| f.status.to_s}.transform_values(&:count)
    counts[:total] = files.size
    OpenStruct.new(counts)
  end

  def save
    return false unless valid?

    FileUtils.mkdir_p(self.class.files_directory(id))
    FileUtils.mkdir_p(download_dir)
    filename = self.class.filename_by_id(id)
    File.open(filename, "w") do |file|
      file.write(to_yaml)
    end
    true
  rescue => e
    log_error('Unable to save project', {id: id, project_path: self.class.files_directory(id)}, e)
    false
  end

  def to_hash
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      hash[attr] = send(attr)
    end
  end

  def to_json
    to_hash.to_json
  end

  def to_yaml
    to_hash.to_yaml
  end

  def to_s
    to_json
  end

  def destroy
    project_path = self.class.projects_directory(id)
    FileUtils.rm_rf(project_path)
  end

  private

  def self.metadata_directory
    File.join(metadata_root_directory, 'projects')
  end

  def self.projects_directory(id)
    File.join(metadata_directory, id)
  end

  def self.files_directory(id)
    File.join(metadata_directory, id, 'files')
  end

  def self.filename_by_id(id)
    File.join(projects_directory(id), "metadata.yml")
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
