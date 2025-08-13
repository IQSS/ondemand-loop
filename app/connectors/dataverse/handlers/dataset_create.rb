module Dataverse::Handlers
  class DatasetCreate
    include LoggingCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      [
        :title,
        :author,
        :description,
        :contact_email,
        :subject
      ]
    end

    def edit(upload_bundle, request_params)
      raise NotImplementedError, 'Only update is supported for DatasetCreate'
    end

    def update(upload_bundle, request_params)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      collection_id = upload_bundle.connector_metadata.collection_id

      log_info('Creating dataset', { upload_bundle: upload_bundle.id, collection_id: collection_id })

      request = Dataverse::CreateDatasetRequest.new(
        title: request_params[:title],
        author: request_params[:author],
        description: request_params[:description],
        contact_email: request_params[:contact_email],
        subjects: [request_params[:subject]]
      )

      service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)
      response = service.create_dataset(collection_id, request)

      metadata = upload_bundle.metadata
      metadata[:dataset_id] = response.persistent_id
      metadata[:dataset_title] = request.title
      upload_bundle.update({ metadata: metadata })
      log_info('Dataset created', { upload_bundle: upload_bundle.id, dataset_id: response.persistent_id })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.handlers.dataset_create.message_success', id: response.persistent_id, title: request.title) },
        success: true
      )
    end
  end
end
