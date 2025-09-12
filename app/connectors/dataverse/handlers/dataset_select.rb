module Dataverse::Handlers
  class DatasetSelect
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [
        :dataset_id
      ]
    end

    def edit(upload_bundle, request_params)
      raise NotImplementedError, 'Only update is supported for DatasetSelect'
    end

    def update(upload_bundle, request_params)
      dataset_id = request_params[:dataset_id]
      dataset_title = dataset_title(upload_bundle, dataset_id)
      metadata = upload_bundle.metadata
      metadata[:dataset_id] = dataset_id
      metadata[:dataset_title] = dataset_title
      upload_bundle.update({ metadata: metadata })

      log_info('Dataset selected', { upload_bundle: upload_bundle.id, dataset_id: dataset_id })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.handlers.dataset_select.message_success', title: dataset_title) },
        success: true
      )
    end

    private

    def datasets(upload_bundle)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      collection_id = upload_bundle.connector_metadata.collection_id
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false, include_drafts: true).data
    end

    def dataset_title(upload_bundle, dataset_id)
      datasets = datasets(upload_bundle)
      datasets.items.select{|d| d.global_id == dataset_id}.first&.name
    end
  end
end
