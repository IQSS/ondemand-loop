module Dataverse::Actions
  class DatasetFormTabs
    def edit(collection, request_params)
      datasets = datasets(collection)
      subjects = subjects(collection)

      ConnectorResult.new(
        partial: '/connectors/dataverse/dataset_form_tabs',
        locals: { collection: collection, data: datasets, subjects: subjects },
      )
    end

    def update(collection, request_params)
      raise NotImplementedError, 'Only edit is supported for DatasetFormTabs'
    end

    private

    def datasets(collection)
      dataverse_url = collection.connector_metadata.dataverse_url
      api_key = collection.connector_metadata.api_key.value
      service = Dataverse::DataverseService.new(dataverse_url, api_key: api_key)
      collection_id = collection.connector_metadata.collection_id
      service.search_dataverse_items(collection_id, 1, 100, false, true).data
    end

    def subjects(collection)
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

      subjects
    end
  end
end