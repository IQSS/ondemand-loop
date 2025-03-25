# frozen_string_literal: true

class DownloadFile < ApplicationDiskRecord
  include ActiveModel::Model

  ATTRIBUTES = %w[id collection_id type metadata_id external_id filename status size checksum content_type].freeze
  TYPES = %w[dataverse].freeze
  STATUS = %w[new ready downloading success error].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of *ATTRIBUTES
  validates :type, inclusion: { in: TYPES, message: "%{value} is not a valid type" }
  validates :status, inclusion: { in: STATUS, message: "%{value} is not a valid status" }
  validates :size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def self.find(collection_id, file_id)
    filename = filename_by_ids(collection_id, file_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def self.new_from_dataverse_file(download_collection, dataset_file)
    new.tap do |f|
      f.id = generate_id
      f.collection_id = download_collection.id
      f.type = 'dataverse'
      f.metadata_id = download_collection.metadata_id
      f.external_id = dataset_file.data_file.id
      f.filename = dataset_file.data_file.filename
      f.status = 'new'
      f.size = dataset_file.data_file.filesize
      f.checksum = dataset_file.data_file.md5
      f.content_type = dataset_file.data_file.content_type
    end
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

  def save
    return false unless valid?

    FileUtils.mkdir_p(self.class.collection_files_directory(collection_id))
    filename = self.class.filename_by_ids(collection_id, id)
    File.open(filename, "w") do |file|
      file.write(to_yaml)
    end
    true
  end

  def progress
    65 #TODO compute current progress from size and current transferred bytes
  end

  private

  def self.metadata_directory
    File.join(metadata_root_directory, Configuration.download_collections_folder)
  end

  def self.collection_directory(collection_id)
    File.join(self.metadata_directory, collection_id)
  end

  def self.collection_files_directory(collection_id)
    File.join(self.metadata_directory, collection_id, 'files')
  end

  def self.filename_by_ids(collection_id, file_id)
    File.join(collection_files_directory(collection_id), "#{file_id}.yml")
  end

  def self.load_from_file(filename)
    data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
    new.tap do |file|
      ATTRIBUTES.each { |attr| file.send("#{attr}=", data[attr]) }
    end
  rescue StandardError
    nil
  end
end
