# frozen_string_literal: true

class UploadBundle < ApplicationDiskRecord
  include ActiveModel::Model
  include FileStatusSummary

  ATTRIBUTES = %w[id project_id remote_repo_url type name creation_date metadata].freeze

  attr_accessor *ATTRIBUTES

  validates_presence_of :id, :project_id, :remote_repo_url, :type, :name

  def self.find(project_id, upload_bundle_id)
    return nil if project_id.blank? || upload_bundle_id.blank?

    filename = filename_by_ids(project_id, upload_bundle_id)
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

  def save
    return false unless valid?

    store_to_file(self.class.filename_by_ids(project_id, id))
  end

  def destroy
    upload_bundle_path = self.class.directory_by_ids(project_id, id)
    FileUtils.rm_rf(upload_bundle_path)
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
  alias_method :status_files, :files

  def connector_metadata
    ConnectorClassDispatcher.upload_bundle_connector_metadata(self)
  end

  private

  def self.directory_by_ids(project_id, upload_bundle_id)
    File.join(Project.upload_bundles_directory(project_id), upload_bundle_id)
  end

  def self.filename_by_ids(project_id, upload_bundle_id)
    File.join(self.directory_by_ids(project_id, upload_bundle_id), "metadata.yml")
  end
end
