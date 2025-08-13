module Dataverse::Handlers
  class DatasetFormTabs
    include LoggingCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      []
    end

    def edit(upload_bundle, request_params)
      datasets = datasets(upload_bundle)
      subjects = subjects(upload_bundle)
      profile = profile(upload_bundle)
      log_info('Dataset form tabs', { upload_bundle: upload_bundle.id, datasets: datasets.items.size, subjects: subjects.size })

      ConnectorResult.new(
        template: '/connectors/dataverse/dataset_form_tabs',
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
      service.search_collection_items(collection_id, page: 1, per_page: 100, include_collections: false, include_drafts: true).data
    end

    def subjects(upload_bundle)
      connector_metadata = upload_bundle.connector_metadata
      repo_db = RepoRegistry.repo_db
      dataverse_data = repo_db.get(connector_metadata.dataverse_url)
      if dataverse_data.metadata.subjects.nil?
        dv_metadata_service = Dataverse::MetadataService.new(connector_metadata.dataverse_url)
        subjects = dv_metadata_service.get_citation_metadata.subjects
        repo_db.update(connector_metadata.dataverse_url, metadata: { subjects: subjects })
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
