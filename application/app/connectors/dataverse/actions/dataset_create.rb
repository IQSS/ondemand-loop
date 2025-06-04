module Dataverse::Actions
  class DatasetCreate
    def edit(upload_bundle, request_params)
      connector_metadata = upload_bundle.connector_metadata
      repo_db = RepoRegistry.repo_db
      dataverse_data = repo_db.get(connector_metadata.server_domain)
      if dataverse_data.metadata.subjects.nil?
        dv_metadata_service = Dataverse::MetadataService.new(connector_metadata.dataverse_url)
        subjects = dv_metadata_service.get_citation_metadata.subjects
        repo_db.update(connector_metadata.server_domain, metadata: { subjects: subjects })
      else
        subjects = dataverse_data.metadata.subjects
      end

      api_key = connector_metadata.api_key.value
      user_service = Dataverse::UserService.new(connector_metadata.dataverse_url, api_key: api_key)
      user_profile = user_service.get_user_profile

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_create_form',
        locals: { upload_bundle: upload_bundle, profile: user_profile, subjects: subjects }
      )
    end

    def update(upload_bundle, request_params)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      collection_id = upload_bundle.connector_metadata.collection_id

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

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.dataset_create.success', id: response.persistent_id, title: request.title) },
        success: true
      )
    end
  end
end