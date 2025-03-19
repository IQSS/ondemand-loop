# frozen_string_literal: true

class DownloadFile < ApplicationDiskRecord
  ATTRIBUTES = %w[id collection_id kind metadata_id external_id filename status size checksum].freeze
  KIND = %w[dataverse].freeze
  STATUS = %w[new ready downloading success error].freeze

  attr_accessor *ATTRIBUTES

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
    FileUtils.mkdir_p(self.class.collection_directory(collection_id))
    filename = self.class.filename_by_ids(collection_id, id)
    File.open(filename, "w") do |file|
      file.write(to_yaml)
    end
    true
  end

  private
  def self.metadata_directory
    metadata_root_directory + Configuration.download_collections_folder
  end

  def self.collection_directory(collection_id)
    self.metadata_directory + "/#{collection_id}"
  end

  def self.filename_by_ids(collection_id, file_id)
    collection_directory(collection_id) + "/#{file_id}.yml"
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
