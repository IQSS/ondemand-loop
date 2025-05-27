module Dataverse::Actions
  class DatasetSelect
    def edit(collection, request_params)
      datasets = datasets(collection)

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_select_form',
        locals: { collection: collection, data: datasets },
      )
    end

    def update(collection, request_params)
      dataset_id = request_params[:dataset_id]
      dataset_title = dataset_title(collection, dataset_id)
      metadata = collection.metadata
      metadata[:dataset_id] = dataset_id
      metadata[:dataset_title] = dataset_title
      collection.update({ metadata: metadata })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.dataset_select.success', title: dataset_title) },
        success: true
      )
    end

    private

    def datasets(collection)
      dataverse_url = collection.connector_metadata.dataverse_url
      api_key = collection.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      collection_id = collection.connector_metadata.collection_id
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false).data
    end

    def dataset_title(collection, dataset_id)
      datasets = datasets(collection)
      datasets.items.select{|d| d.global_id == dataset_id}.first&.name
    end
  end
end