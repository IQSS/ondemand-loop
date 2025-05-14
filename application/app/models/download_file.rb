# frozen_string_literal: true

class DownloadFile < ApplicationDiskRecord
  include ActiveModel::Model
  include LoggingCommon

  ATTRIBUTES = %w[id project_id type filename status size creation_date start_date end_date metadata].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of :id, :project_id, :type, :filename, :status, :size
  validates :size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def self.metadata_path(project_id, file_id)
    File.join(Project.download_files_directory(project_id), "#{file_id}.yml")
  end
  def self.find(project_id, file_id)
    file_metadata = metadata_path(project_id, file_id)
    return nil unless File.exist?(file_metadata)

    load_from_file(file_metadata)
  end

  def type=(value)
    raise ArgumentError, "Invalid type: #{value}" unless value.is_a?(ConnectorType)

    @type = value
  end

  def status=(value)
    raise ArgumentError, "Invalid status: #{value}" unless value.is_a?(FileStatus)

    @status = value
  end

  # TODO: Should be call this to_h instead?
  def to_hash
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      if ['type', 'status'].include?(attr)
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

    FileUtils.mkdir_p(Project.download_files_directory(project_id))
    filename = self.class.metadata_path(project_id, id)
    File.open(filename, "w") do |file|
      file.write(to_hash.deep_stringify_keys.to_yaml)
    end
    true
  end

  def destroy
    file_path = self.class.metadata_path(project_id, id)
    FileUtils.rm(file_path)
  end

  def connector_status
    ConnectorClassDispatcher.download_connector_status(self)
  end

  def connector_metadata
    ConnectorClassDispatcher.download_connector_metadata(self)
  end

  private

  def self.load_from_file(file_metadata)
    data = YAML.safe_load(File.read(file_metadata), permitted_classes: [Hash], aliases: true)
    new.tap do |file|
      ATTRIBUTES.each do |attr|
        case attr
        when 'type'
          file.type = ConnectorType.get(data['type'])
        when 'status'
          file.status = FileStatus.get(data['status'])
        else
          file.send("#{attr}=", data[attr])
        end
      end
    end
  rescue StandardError => e
    LoggingCommon.log_error('Cannon load file metadata', {file_metadata: file_metadata}, e)
    nil
  end
end
