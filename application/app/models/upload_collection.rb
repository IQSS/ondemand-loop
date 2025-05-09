# frozen_string_literal: true

class UploadCollection < ApplicationDiskRecord
  include ActiveModel::Model
  include LoggingCommon

  ATTRIBUTES = %w[id project_id type name creation_date metadata].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of :id, :project_id, :type

  def self.find(project_id, collection_id)
    filename = filename_by_ids(project_id, collection_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  def type=(value)
    raise ArgumentError, "Invalid type: #{value}" unless value.is_a?(ConnectorType)

    @type = value
  end

  # TODO: Should be call this to_h instead?
  def to_hash
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      if ['type'].include?(attr)
        hash[attr] = send(attr).to_s
      else
        hash[attr] = send(attr)
      end
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

    FileUtils.mkdir_p(File.join(self.class.directory_by_ids(project_id, id), "files"))
    filename = self.class.filename_by_ids(project_id, id)
    File.open(filename, "w") do |file|
      file.write(to_hash.deep_stringify_keys.to_yaml)
    end
    true
  end

  def files
    @upload_files ||=
      begin
        directory = File.join(self.class.directory_by_ids(project_id, id), "files")
        Dir.glob(File.join(directory, '*.yml'))
           .select { |f| File.file?(f) }
           .sort_by { |f| File.ctime(f) }
           .map { |f| UploadFile.find(project_id, id, File.basename(f, ".yml")) }
           .compact
      end
  end

  def connector_metadata
    ConnectorClassDispatcher.connector_metadata(self)
  end

  private

  def self.directory_by_ids(project_id, collection_id)
    File.join(Project.upload_collections_directory(project_id), collection_id)
  end

  def self.filename_by_ids(project_id, collection_id)
    File.join(self.directory_by_ids(project_id, collection_id), "metadata.yml")
  end

  def self.load_from_file(filename)
    data = YAML.safe_load(File.read(filename), permitted_classes: [Hash], aliases: true)
    new.tap do |file|
      ATTRIBUTES.each do |attr|
        case attr
        when 'type'
          file.type = ConnectorType.get(data['type'])
        else
          file.send("#{attr}=", data[attr])
        end
      end
    end
  rescue StandardError => e
    LoggingCommon.log_error('Cannon load file metadata', {file: filename}, e)
    nil
  end
end
