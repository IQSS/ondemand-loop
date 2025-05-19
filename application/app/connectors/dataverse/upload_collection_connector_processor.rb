# frozen_string_literal: true

module Dataverse
  # Dataverse upload collection connector processor. Responsible for managing updates to collections of type Dataverse
  class UploadCollectionConnectorProcessor
    include LoggingCommon
    include DateTimeCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def create(project, request_params)
      dataset_url = request_params[:dataset_url]
      repo_url = Repo::RepoUrlParser.parse(dataset_url)
      if repo_url.nil? || repo_url.domain.blank? || repo_url.doi.blank?
        return ConnectorResult.new(
          message: { alert: "Invalid dataset URL: #{dataset_url}" },
          success: false
        )
      end

      dv_service = Dataverse::DataverseService.new(repo_url.repo_url)
      dataset = dv_service.find_dataset_version_by_persistent_id(repo_url.doi)

      file_utils = Common::FileUtils.new
      upload_collection = UploadCollection.new.tap do |c|
        c.id = file_utils.normalize_name(File.join(repo_url.domain, UploadCollection.generate_code))
        c.name = repo_url.domain
        c.project_id = project.id
        c.remote_repo_url = dataset_url
        c.type = ConnectorType::DATAVERSE
        c.creation_date = now
        c.metadata = {
          title: dataset.metadata_field('title').to_s,
          dataverse_url: repo_url.repo_url,
          persistent_id: repo_url.doi
        }
      end
      upload_collection.save

      ConnectorResult.new(
        message: { notice: "Upload Collection created: #{upload_collection.name}" },
        success: true
      )
    end

    def edit(collection)
      ConnectorResult.new(
        partial: '/connectors/dataverse/upload_collection_form',
        locals: { collection: collection },
        message: { notice: "Loaded connector form" }
      )
    end

    def update(collection, request_params)
      dataset_url = request_params[:remote_repo_url]
      repo_key = request_params[:api_key]
      repo_url = Repo::RepoUrlParser.parse(dataset_url)
      if repo_url.nil? || repo_url.domain.blank? || repo_url.doi.blank?
        return ConnectorResult.new(
          message: { alert: "Invalid dataset URL: #{dataset_url}" },
          success: false
        )
      end

      dv_service = Dataverse::DataverseService.new(repo_url.repo_url)
      dataset = dv_service.find_dataset_version_by_persistent_id(repo_url.doi)

      metadata = collection.metadata
      metadata[:title] = dataset.metadata_field('title').to_s
      metadata[:dataverse_url] = repo_url.repo_url
      metadata[:persistent_id] = repo_url.doi
      metadata[:api_key] = repo_key
      collection.update({remote_repo_url: dataset_url, metadata: metadata})

      ConnectorResult.new(
        message: { notice: "Upload Collection updated: #{collection.name}" },
        success: true
      )
    end

  end
end