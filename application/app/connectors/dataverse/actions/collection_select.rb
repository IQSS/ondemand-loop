module Dataverse::Actions
  class CollectionSelect
    def edit(upload_bundle, request_params)
      collections = collections(upload_bundle)

      ConnectorResult.new(
        partial: '/connectors/dataverse/collection_select_form',
        locals: { upload_bundle: upload_bundle, data: collections },
      )
    end

    def update(upload_bundle, request_params)
      collection_id = request_params[:collection_id]
      collection_title = collection_title(upload_bundle, collection_id)
      metadata = upload_bundle.metadata
      metadata[:collection_id] = collection_id
      metadata[:collection_title] = collection_title
      upload_bundle.update({ metadata: metadata })

      ConnectorResult.new(
        redirect_url: Rails.application.routes.url_helpers.project_path(id: upload_bundle.project_id, anchor: "tab-#{upload_bundle.id}"),
        message: { notice: I18n.t('connectors.dataverse.actions.collection_select.success', title: collection_title) },
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
      collections = collections(upload_bundle)
      collections.items.select{|c| c.identifier == collection_id}.first&.name
    end
  end
end