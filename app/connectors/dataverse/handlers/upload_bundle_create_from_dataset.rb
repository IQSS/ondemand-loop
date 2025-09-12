# frozen_string_literal: true

module Dataverse::Handlers
  class UploadBundleCreateFromDataset
    include LoggingCommon
    include DateTimeCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [:object_url]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Dataverse::DataverseUrl.parse(remote_repo_url)
      log_info('Creating upload bundle from dataset', { project_id: project.id, remote_repo_url: remote_repo_url })

      # Get API key from repository configuration
      repo_info = ::Configuration.repo_db.get(url_data.dataverse_url)
      api_key = repo_info&.metadata&.auth_key

      # If it's a draft dataset and there's no API key, find_dataset_version_by_persistent_id will fail.
      # Fetch root collection to display in the UI
      if url_data.draft? && api_key.nil?
        collection_service = Dataverse::CollectionService.new(url_data.dataverse_url)
        root = collection_service.find_collection_by_id(':root')
        root_title = root.data.name
        collection_title = root.data.alias
        collection_id = root.data.alias
      else
        dataset_service = Dataverse::DatasetService.new(url_data.dataverse_url, api_key: api_key)
        dataset = dataset_service.find_dataset_version_by_persistent_id(url_data.dataset_id, version: url_data.version)
        return error(I18n.t('connectors.dataverse.handlers.upload_bundle_create_from_dataset.message_dataset_not_found', url: remote_repo_url)) unless dataset

        if dataset.data.parents.empty?
          collection_service = Dataverse::CollectionService.new(url_data.dataverse_url, api_key: api_key)
          collection = collection_service.find_collection_by_id(':root')
          root_title = collection.data.name
          collection_title = collection.data.alias
          collection_id = collection.data.alias
        else
          parent_dv = dataset.data.parents.last
          root_dv = dataset.data.parents.first
          root_title = root_dv[:name]
          collection_title = parent_dv[:name]
          collection_id = parent_dv[:identifier]
        end

        dataset_title = dataset.metadata_field('title').to_s
      end

      ::Configuration.repo_history.add_repo(
        remote_repo_url,
        ConnectorType::DATAVERSE,
        title: dataset_title || url_data.dataset_id,
        note: url_data.version
      )

      file_utils = Common::FileUtils.new
      upload_bundle = UploadBundle.new.tap do |bundle|
        bundle.id = file_utils.normalize_name(File.join(url_data.domain, UploadBundle.generate_code))
        bundle.name = url_data.domain
        bundle.project_id = project.id
        bundle.remote_repo_url = remote_repo_url
        bundle.type = ConnectorType::DATAVERSE
        bundle.creation_date = now
        bundle.metadata = {
          dataverse_url: url_data.dataverse_url,
          dataverse_title: root_title,
          collection_title: collection_title,
          dataset_title: dataset_title,
          collection_id: collection_id,
          dataset_id: url_data.dataset_id,
        }
      end
      upload_bundle.save
      log_info('Upload bundle created from dataset', { bundle_id: upload_bundle.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.dataverse.handlers.upload_bundle_create_from_dataset.message_success', name: upload_bundle.name) },
        success: true
      )

    rescue Dataverse::DatasetService::UnauthorizedException => e
      log_error('Repo URL requires authentication', { dataverse: remote_repo_url }, e)
      return error(I18n.t('connectors.dataverse.handlers.upload_bundle_create_from_dataset.message_authentication_error', url: remote_repo_url))
    end

    private

    def error(message)
      ConnectorResult.new(
        message: { alert: message },
        success: false
      )
    end
  end
end