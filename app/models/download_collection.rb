# frozen_string_literal: true

class DownloadCollection < ApplicationDiskRecord
  include ActiveModel::Model

  ATTRIBUTES = %w[id kind metadata_id]
  KIND = %w[dataverse]

  attr_accessor *ATTRIBUTES

  validates_presence_of *ATTRIBUTES
  validates :kind, inclusion: { in: KIND }

  def self.all
    Dir.glob(metadata_directory).map do |directory|
      load_metadata_from_directory(directory)
    end.compact
  end

  def self.find(collection_id)
    filename = filename_by_id(collection_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def files
    directory = self.class.collection_directory(id)
    Dir.glob(directory).reject {|f| f == "metadata.yml" }.map do |filename|
      file_id = filename.split(".yml").first
      DownloadFile.find(id, file_id)
    end.compact
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
    metadata_root_directory + Configuration.download_collections_folder
  end

  def self.collection_directory(id)
    metadata_directory + "#{id}"
  end

  def self.filename_by_id(id)
    collection_directory(id) + "/metadata.yml"
  end

  def load_metadata_from_directory(directory)
    metadata_file = File.join(directory, 'metadata.yml')
    self.class.load_from_file(metadata_file)
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
