module Dataverse::Actions
  class DatasetSelect
    def edit(upload_batch, request_params)
      datasets = datasets(upload_batch)

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_select_form',
        locals: { upload_batch: upload_batch, data: datasets },
      )
    end

    def update(upload_batch, request_params)
      dataset_id = request_params[:dataset_id]
      dataset_title = dataset_title(upload_batch, dataset_id)
      metadata = upload_batch.metadata
      metadata[:dataset_id] = dataset_id
      metadata[:dataset_title] = dataset_title
      upload_batch.update({ metadata: metadata })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.dataset_select.success', title: dataset_title) },
        success: true
      )
    end

    private

    def datasets(upload_batch)
      dataverse_url = upload_batch.connector_metadata.dataverse_url
      api_key = upload_batch.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      collection_id = upload_batch.connector_metadata.collection_id
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false).data
    end

    def dataset_title(upload_batch, dataset_id)
      datasets = datasets(upload_batch)
      datasets.items.select{|d| d.global_id == dataset_id}.first&.name
    end
  end
end