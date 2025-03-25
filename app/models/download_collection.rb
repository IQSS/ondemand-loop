# frozen_string_literal: true

class DownloadCollection < ApplicationDiskRecord
  include ActiveModel::Model

  ATTRIBUTES = %w[id type metadata_id name].freeze
  TYPES = %w[dataverse]

  attr_accessor *ATTRIBUTES

  validates_presence_of *ATTRIBUTES
  validates :type, inclusion: { in: TYPES }

  def self.all
    Dir.glob(File.join(metadata_directory, '*'))
       .select { |path| File.directory?(path) }
       .sort_by { |directory| File.ctime(directory) }
       .reverse
       .map { |directory| load_metadata_from_directory(directory) }
       .compact
  end

  def self.new_from_dataverse(dataverse_metadata)
    new.tap do |collection|
      collection.id = generate_id
      collection.type = "dataverse"
      collection.metadata_id = dataverse_metadata.id
    end
  end

  def self.find(collection_id)
    filename = filename_by_id(collection_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def files
    directory = self.class.collection_directory(id)
    Dir.glob(File.join(directory, '*.yml'))
       .select { |f| File.file?(f) }
       .reject { |f| File.basename(f) == "metadata.yml" }
       .sort_by { |f| File.ctime(f) }
       .map { |f | DownloadFile.find(id, File.basename(f, ".yml")) }
       .compact
  end

  def save
    return false unless valid?

    FileUtils.mkdir_p(self.class.collection_directory(id))
    filename = self.class.filename_by_id(id)
    File.open(filename, "w") do |file|
      file.write(to_yaml)
    end
    true
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

  private

  def self.metadata_directory
    File.join(metadata_root_directory, Configuration.download_collections_folder)
  end

  def self.collection_directory(id)
    File.join(metadata_directory, id)
  end

  def self.filename_by_id(id)
    File.join(collection_directory(id), "metadata.yml")
  end

  def self.load_metadata_from_directory(directory)
    metadata_file = File.join(directory, 'metadata.yml')
    load_from_file(metadata_file)
  end

  def self.load_from_file(filename)
    data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
    new.tap do |collection|
      ATTRIBUTES.each { |attr| collection.send("#{attr}=", data[attr]) }
    end
  rescue StandardError
    nil
  end
end
