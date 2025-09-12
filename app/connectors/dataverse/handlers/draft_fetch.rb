# frozen_string_literal: true

module Dataverse::Handlers
  class DraftFetch
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      []
    end

    def update(upload_bundle, request_params)
      connector_metadata = upload_bundle.connector_metadata
      dataverse_url = connector_metadata.dataverse_url
      dataset_id = connector_metadata.dataset_id
      api_key = connector_metadata.api_key&.value

      return error(I18n.t('connectors.dataverse.handlers.draft_fetch.message_no_api_key')) unless api_key
      return error(I18n.t('connectors.dataverse.handlers.draft_fetch.message_no_dataset_id')) unless dataset_id

      log_info('Fetching draft dataset data', { upload_bundle: upload_bundle.id, dataset_id: dataset_id })

      dataset_service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)
      dataset = dataset_service.find_dataset_version_by_persistent_id(dataset_id, version: ':draft')

      return error(I18n.t('connectors.dataverse.handlers.draft_fetch.message_dataset_not_found')) unless dataset

      # Update metadata with fetched dataset information
      metadata = upload_bundle.metadata
      dataset_title = dataset.metadata_field('title').to_s
      metadata[:dataset_title] = dataset_title

      # Update parent collection info if available
      if dataset.data.parents.present?
        parent_dv = dataset.data.parents.last
        metadata[:collection_title] = parent_dv[:name]
        metadata[:collection_id] = parent_dv[:identifier]
      end

      # Add to repo history
      ::Configuration.repo_history.add_repo(
        upload_bundle.remote_repo_url,
        ConnectorType::DATAVERSE,
        title: dataset_title,
        note: dataset.version
      )

      upload_bundle.update({ metadata: metadata })

      log_info('Draft dataset data fetched successfully', {
        upload_bundle: upload_bundle.id,
        dataset_id: dataset_id,
        dataset_title: dataset_title
      })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.handlers.draft_fetch.message_success', title: dataset_title) },
        success: true
      )

      rescue Dataverse::DatasetService::UnauthorizedException => e
        log_error('Unauthorized access to draft dataset', { dataset_id: dataset_id }, e)
        error(I18n.t('connectors.dataverse.handlers.draft_fetch.message_unauthorized'))
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