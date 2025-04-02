# frozen_string_literal: true

class DownloadFile < ApplicationDiskRecord
  include ActiveModel::Model
  include LoggingCommon

  ATTRIBUTES = %w[id collection_id type filename status size metadata].freeze
  TYPES = %w[dataverse].freeze
  STATUS = %w[ready downloading success error].freeze

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
      file.write(to_hash.deep_stringify_keys.to_yaml)
    end
    true
  end

  def save_status!(status)
    self.status = status
    save
  end

  def connector_status
    ConnectorClassDispatcher.file_connector_status(self)
  end

  def connector_metadata
    ConnectorClassDispatcher.connector_metadata(self)
  end

  private

  #TODO: This needs to be taken from the DownloadCollection object
  def self.metadata_directory
    File.join(metadata_root_directory, 'collections')
  end

  def self.collection_directory(collection_id)
    File.join(self.metadata_directory, collection_id)
  end

  #TODO: This needs to be taken from the DownloadCollection object
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
  rescue StandardError => e
    Rails.logger.error(e.message)
    nil
  end
end
