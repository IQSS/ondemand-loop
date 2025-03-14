# frozen_string_literal: true

class DownloadCollection < ApplicationDiskRecord
  attr_accessor :id, :kind

  def self.all
    Dir.glob(metadata_directory).map do |directory|
      load_metadata_from_directory(directory)
    end.compact
  end

  private

  def self.metadata_directory
    metadata_root_directory + Configuration.download_collections_folder
  end

  def load_metadata_from_directory(directory)
    metadata_file = File.join(directory, 'metadata.yml')
    data = YAML.safe_load(File.read(metadata_file), permitted_classes: [Hash], aliases: true)
    new.tap do |collection|
      collection.id = data["id"]
      collection.kind = data["kind"]
    end
  rescue StandardError
    nil
  end
end
