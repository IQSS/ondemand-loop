module Dataverse::Actions
  class CollectionSelect
    def edit(collection, request_params)
      collections = collections(collection)

      ConnectorResult.new(
        partial: '/connectors/dataverse/collection_select_form',
        locals: { collection: collection, data: collections },
      )
    end

    def update(collection, request_params)
      collection_id = request_params[:collection_id]
      collection_title = collection_title(collection, collection_id)
      metadata = collection.metadata
      metadata[:collection_id] = collection_id
      metadata[:collection_title] = collection_title
      collection.update({ metadata: metadata })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.collection_select.success', title: collection_title) },
        success: true
      )
    end

    private

    def collections(collection)
      dataverse_url = collection.connector_metadata.dataverse_url
      api_key = collection.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      service.get_my_collections
    end

    def collection_title(collection, collection_id)
      collections = collections(collection)
      collections.items.select{|c| c.identifier == collection_id}.first&.name
    end
  end
end