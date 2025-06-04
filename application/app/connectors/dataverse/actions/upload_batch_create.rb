module Dataverse::Actions
  class UploadBatchCreate
    include LoggingCommon
    include DateTimeCommon

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      dataverse_url = Dataverse::DataverseUrl.parse(remote_repo_url)

      if dataverse_url.collection?
        collection_service = Dataverse::CollectionService.new(dataverse_url.dataverse_url)
        collection = collection_service.find_collection_by_id(dataverse_url.collection_id)
        return error(I18n.t('connectors.dataverse.upload_bundles.collection_not_found', url: remote_repo_url)) unless collection

        root_dv = collection.data.parents.first
        root_title = root_dv[:name]
        collection_title = collection.data.name
      elsif dataverse_url.dataset?
        dataset_service = Dataverse::DatasetService.new(dataverse_url.dataverse_url)
        dataset = dataset_service.find_dataset_version_by_persistent_id(dataverse_url.dataset_id)
        return error(I18n.t('connectors.dataverse.upload_bundles.dataset_not_found', url: remote_repo_url)) unless dataset

        parent_dv = dataset.data.parents.last
        root_dv = dataset.data.parents.first
        root_title = root_dv[:name]
        collection_title = parent_dv[:name]
        dataset_title = dataset.metadata_field('title').to_s
      else
        collection_service = Dataverse::CollectionService.new(dataverse_url.dataverse_url)
        collection = collection_service.find_collection_by_id(':root')
        root_title = collection.data.name
      end

      file_utils = Common::FileUtils.new
      upload_bundle = UploadBundle.new.tap do |bundle|
        bundle.id = file_utils.normalize_name(File.join(dataverse_url.domain, UploadBundle.generate_code))
        bundle.name = bundle.id
        bundle.project_id = project.id
        bundle.remote_repo_url = remote_repo_url
        bundle.type = ConnectorType::DATAVERSE
        bundle.creation_date = now
        bundle.metadata = {
          dataverse_url: dataverse_url.dataverse_url,
          dataverse_title: root_title,
          collection_title: collection_title,
          dataset_title: dataset_title,
          collection_id: dataverse_url.collection_id,
          dataset_id: dataverse_url.dataset_id,
        }
      end
      upload_bundle.save

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.dataverse.upload_bundles.created', name: upload_bundle.name) },
        success: true
      )
    end

    private

    def error(message)
      ConnectorResult.new(
        message: { alert: message },
        success: false
      )
    end
  end
end