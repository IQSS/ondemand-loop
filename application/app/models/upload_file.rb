# frozen_string_literal: true

class UploadFile < ApplicationDiskRecord
  include ActiveModel::Model

  ATTRIBUTES = %w[id project_id collection_id type file_location filename status size creation_date start_date end_date].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of :id, :project_id, :collection_id, :type, :file_location, :filename, :status, :size
  validates :size, file_size: { max: :max_file_size }

  def self.find(project_id, collection_id, file_id)
    return nil if project_id.blank? || collection_id.blank? || file_id.blank?

    filename = filename_by_ids(project_id, collection_id, file_id)
    return nil unless File.exist?(filename)

    load_from_file(filename)
  end

  #TODO: Remove from UploadFile - UploadCollection is the one with the type
  def type=(value)
    raise ArgumentError, "Invalid type: #{value}" unless value.is_a?(ConnectorType)

    @type = value
  end

  def status=(value)
    raise ArgumentError, "Invalid status: #{value}" unless value.is_a?(FileStatus)

    @status = value
  end

  def save
    return false unless valid?

    store_to_file(self.class.filename_by_ids(project_id, collection_id, id))
  end

  def destroy
    filename = self.class.filename_by_ids(project_id, collection_id, id)
    FileUtils.rm(filename)
  end

  def upload_batch
    @upload_batch ||= UploadBatch.find(project_id, collection_id)
  end

  def project
    @project ||= Project.find(project_id)
  end

  def connector_status
    ConnectorClassDispatcher.upload_file_connector_status(self)
  end

  def connector_metadata
    ConnectorClassDispatcher.upload_connector_metadata(self)
  end

  def max_file_size
    Configuration.max_upload_file_size
  end

  private

  def self.filename_by_ids(project_id, collection_id, file_id)
    File.join(Project.upload_batches_directory(project_id), collection_id, "files", "#{file_id}.yml")
  end
end
