module Dataverse::Actions
  class DatasetSelect
    def edit(upload_bundle, request_params)
      datasets = datasets(upload_bundle)

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_select_form',
        locals: { upload_bundle: upload_bundle, data: datasets },
      )
    end

    def update(upload_bundle, request_params)
      dataset_id = request_params[:dataset_id]
      dataset_title = dataset_title(upload_bundle, dataset_id)
      metadata = upload_bundle.metadata
      metadata[:dataset_id] = dataset_id
      metadata[:dataset_title] = dataset_title
      upload_bundle.update({ metadata: metadata })

      ConnectorResult.new(
        redirect_url: Rails.application.routes.url_helpers.project_path(id: upload_bundle.project_id, anchor: "tab-#{upload_bundle.id}"),
        message: { notice: I18n.t('connectors.dataverse.actions.dataset_select.success', title: dataset_title) },
        success: true
      )
    end

    private

    def datasets(upload_bundle)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      collection_id = upload_bundle.connector_metadata.collection_id
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false).data
    end

    def dataset_title(upload_bundle, dataset_id)
      datasets = datasets(upload_bundle)
      datasets.items.select{|d| d.global_id == dataset_id}.first&.name
    end
  end
end