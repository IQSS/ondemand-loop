module Dataverse::Actions
  class DatasetFormTabs
    def edit(upload_bundle, request_params)
      datasets = datasets(upload_bundle)
      subjects = subjects(upload_bundle)
      profile = profile(upload_bundle)

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_form_tabs',
        locals: { upload_bundle: upload_bundle, data: datasets, profile: profile, subjects: subjects },
      )
    end

    def update(upload_bundle, request_params)
      raise NotImplementedError, 'Only edit is supported for DatasetFormTabs'
    end

    private

    def datasets(upload_bundle)
      dataverse_url = upload_bundle.connector_metadata.dataverse_url
      api_key = upload_bundle.connector_metadata.api_key.value
      service = Dataverse::CollectionService.new(dataverse_url, api_key: api_key)
      collection_id = upload_bundle.connector_metadata.collection_id
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false).data
    end

    def subjects(upload_bundle)
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

      subjects
    end

    def profile(upload_bundle)
      connector_metadata = upload_bundle.connector_metadata
      api_key = connector_metadata.api_key.value
      user_service = Dataverse::UserService.new(connector_metadata.dataverse_url, api_key: api_key)
      user_service.get_user_profile
    end
  end
end