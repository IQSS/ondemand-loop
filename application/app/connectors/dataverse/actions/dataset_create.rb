module Dataverse::Actions
  class DatasetCreate
    def edit(collection, request_params)
      connector_metadata = collection.connector_metadata
      repo_db = RepoRegistry.repo_db
      dataverse_data = repo_db.get(connector_metadata.server_domain)
      if dataverse_data.metadata.subjects.nil?
        dv_service = Dataverse::DataverseService.new(connector_metadata.dataverse_url)
        subjects = dv_service.get_citation_metadata.subjects
        repo_db.update(connector_metadata.server_domain, metadata: { subjects: subjects })
      else
        subjects = dataverse_data.metadata.subjects
      end

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_create_form',
        locals: { collection: collection, subjects: subjects }
      )
    end

    def update(collection, request_params)
      dataverse_url = collection.connector_metadata.dataverse_url
      api_key = collection.connector_metadata.api_key.value
      collection_id = collection.connector_metadata.collection_id

      request = Dataverse::CreateDatasetRequest.new(
        title: request_params[:title],
        author: request_params[:author],
        description: request_params[:description],
        contact_email: request_params[:contact_email],
        subjects: [request_params[:subject]]
      )

      service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)
      response = service.create_dataset(collection_id, request)

      metadata = collection.metadata
      metadata[:dataset_id] = response.persistent_id
      metadata[:dataset_title] = request.title
      collection.update({ metadata: metadata })

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.dataset_create.success', id: response.persistent_id, title: request.title) },
        success: true
      )
    end
  end
end