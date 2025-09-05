module Dataverse::Handlers
  class CollectionSelect
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [
        :collection_id
      ]
    end

    def edit(upload_bundle, request_params)
      user_collections_response = collections(upload_bundle)
      log_info('Collection select edit', { upload_bundle: upload_bundle.id, collections: user_collections_response.items.size })

      ConnectorResult.new(
        template: '/connectors/dataverse/collection_select_form',
        locals: { upload_bundle: upload_bundle, data: user_collections_response },
      )
    end

    def update(upload_bundle, request_params)
      collection_id = request_params[:collection_id]
      collection_title = collection_title(upload_bundle, collection_id)
      metadata = upload_bundle.metadata
      metadata[:collection_id] = collection_id
      metadata[:collection_title] = collection_title
      upload_bundle.update({ metadata: metadata })

      log_info('Collection selected', { upload_bundle: upload_bundle.id, collection_id: collection_id })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.handlers.collection_select.message_success', title: collection_title) },
        success: true
      )
    end

    private

    def collections(upload_bundle)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      service.get_my_collections
    end

    def collection_title(upload_bundle, collection_id)
      user_collections_response = collections(upload_bundle)
      user_collections_response.items.select { |c| c.identifier == collection_id }.first&.name
    end
  end
end
