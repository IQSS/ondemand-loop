# frozen_string_literal: true

module Dataverse
  # Dataverse upload batch connector processor. Responsible for managing updates to collections of type Dataverse
  class UploadBatchConnectorProcessor
    include LoggingCommon
    include DateTimeCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[remote_repo_url form api_key key_scope collection_id dataset_id title description author contact_email subject]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      dataverse_url = Dataverse::DataverseUrl.parse(remote_repo_url)

      if dataverse_url.collection?
        collection_service = Dataverse::CollectionService.new(dataverse_url.dataverse_url)
        collection = collection_service.find_collection_by_id(dataverse_url.collection_id)
        return error(I18n.t('connectors.dataverse.upload_batches.collection_not_found', url: remote_repo_url)) unless collection

        root_dv = collection.data.parents.first
        root_title = root_dv[:name]
        collection_title = collection.data.name
      elsif dataverse_url.dataset?
        dataset_service = Dataverse::DatasetService.new(dataverse_url.dataverse_url)
        dataset = dataset_service.find_dataset_version_by_persistent_id(dataverse_url.dataset_id)
        return error(I18n.t('connectors.dataverse.upload_batches.dataset_not_found', url: remote_repo_url)) unless dataset

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
      upload_batch = UploadBatch.new.tap do |batch|
        batch.id = file_utils.normalize_name(File.join(dataverse_url.domain, UploadBatch.generate_code))
        batch.name = batch.id
        batch.project_id = project.id
        batch.remote_repo_url = remote_repo_url
        batch.type = ConnectorType::DATAVERSE
        batch.creation_date = now
        batch.metadata = {
          dataverse_url: dataverse_url.dataverse_url,
          dataverse_title: root_title,
          collection_title: collection_title,
          dataset_title: dataset_title,
          collection_id: dataverse_url.collection_id,
          dataset_id: dataverse_url.dataset_id,
        }
      end
      upload_batch.save

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.upload_batches.created', name: upload_batch.name) },
        success: true
      )
    end

    def edit(upload_batch, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Dataverse::Actions::DatasetFormTabs.new.edit(upload_batch, request_params)
      when 'dataset_create'
        Dataverse::Actions::DatasetCreate.new.edit(upload_batch, request_params)
      when 'dataset_select'
        Dataverse::Actions::DatasetSelect.new.edit(upload_batch, request_params)
      when 'collection_select'
        Dataverse::Actions::CollectionSelect.new.edit(upload_batch, request_params)
      else
        Dataverse::Actions::ConnectorEdit.new.edit(upload_batch, request_params)
      end
    end

    def update(upload_batch, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Dataverse::Actions::DatasetFormTabs.new.update(upload_batch, request_params)
      when 'dataset_create'
        Dataverse::Actions::DatasetCreate.new.update(upload_batch, request_params)
      when 'dataset_select'
        Dataverse::Actions::DatasetSelect.new.update(upload_batch, request_params)
      when 'collection_select'
        Dataverse::Actions::CollectionSelect.new.update(upload_batch, request_params)
      else
        Dataverse::Actions::ConnectorEdit.new.update(upload_batch, request_params)
      end
    end

    private

    def error(message)
      ConnectorResult.new(
        message: { alert: message },
        success: true
      )
    end

  end
end