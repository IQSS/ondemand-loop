# frozen_string_literal: true

class DownloadFile < ApplicationDiskRecord
  include ActiveModel::Model

  ATTRIBUTES = %w[id project_id type filename status size creation_date start_date end_date metadata].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of :id, :project_id, :type, :filename, :status, :size
  validates :size, file_size: { max: :max_file_size }

  def self.metadata_path(project_id, file_id)
    File.join(Project.download_files_directory(project_id), "#{file_id}.yml")
  end
  def self.find(project_id, file_id)
    return nil if project_id.blank? || file_id.blank?

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

  def download_location
    @project ||= Project.find(project_id)
    return nil unless @project

    File.join(@project.download_dir, filename)
  end

  def download_tmp_location
    location = download_location
    return nil unless location

    "#{location}.part"
  end

  def save
    return false unless valid?

    store_to_file(self.class.metadata_path(project_id, id))
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

  def restart_possible?
    FileStatus.retryable_statuses.include?(status) && connector_metadata.partial_downloads != false
  end

  def max_file_size
    Configuration.max_download_file_size
  end

end
