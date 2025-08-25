module Dataverse::Handlers
  class UploadBundleCreate
    include LoggingCommon

    include DateTimeCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      [
        :object_url
      ]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Dataverse::DataverseUrl.parse(remote_repo_url)
      log_info('Creating upload bundle', { project_id: project.id, remote_repo_url: remote_repo_url })

      repo_history_note = nil

      if url_data.collection?
        collection_service = Dataverse::CollectionService.new(url_data.dataverse_url)
        collection = collection_service.find_collection_by_id(url_data.collection_id)
        return error(I18n.t('connectors.dataverse.handlers.upload_bundle_create.message_collection_not_found', url: remote_repo_url)) unless collection

        root_dv = collection.data.parents.first || {}
        root_title = root_dv[:name]
        collection_title = collection.data.name
        collection_id = collection.data.alias
        repo_history_note = 'collection'
      elsif url_data.dataset?
        dataset_service = Dataverse::DatasetService.new(url_data.dataverse_url)
        dataset = dataset_service.find_dataset_version_by_persistent_id(url_data.dataset_id)
        return error(I18n.t('connectors.dataverse.handlers.upload_bundle_create.message_dataset_not_found', url: remote_repo_url)) unless dataset

        if dataset.data.parents.empty?
          collection_service = Dataverse::CollectionService.new(url_data.dataverse_url)
          collection = collection_service.find_collection_by_id(':root')
          root_title = collection.data.name
          collection_title = collection.data.alias
          collection_id = collection.data.alias
        else
          parent_dv = dataset.data.parents.last
          root_dv = dataset.data.parents.first
          root_title = root_dv[:name]
          collection_title = parent_dv[:name]
          collection_id = parent_dv[:identifier]
        end

        dataset_title = dataset.metadata_field('title').to_s
        repo_history_note = dataset.version
      else
        collection_service = Dataverse::CollectionService.new(url_data.dataverse_url)
        collection = collection_service.find_collection_by_id(':root')
        root_title = collection.data.name
        repo_history_note = 'dataverse'
      end

      RepoRegistry.repo_history.add_repo(
        remote_repo_url,
        ConnectorType::DATAVERSE,
        title: dataset_title || collection_title || root_title,
        note: repo_history_note
      )

      file_utils = Common::FileUtils.new
      upload_bundle = UploadBundle.new.tap do |bundle|
        bundle.id = file_utils.normalize_name(File.join(url_data.domain, UploadBundle.generate_code))
        bundle.name = url_data.domain
        bundle.project_id = project.id
        bundle.remote_repo_url = remote_repo_url
        bundle.type = ConnectorType::DATAVERSE
        bundle.creation_date = now
        bundle.metadata = {
          dataverse_url: url_data.dataverse_url,
          dataverse_title: root_title,
          collection_title: collection_title,
          dataset_title: dataset_title,
          collection_id: collection_id,
          dataset_id: url_data.dataset_id,
        }
      end
      upload_bundle.save
      log_info('Upload bundle created', { bundle_id: upload_bundle.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.dataverse.handlers.upload_bundle_create.message_success', name: upload_bundle.name) },
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
