# frozen_string_literal: true

module Dataverse
  # Dataverse upload collection connector processor. Responsible for managing updates to collections of type Dataverse
  class UploadCollectionConnectorProcessor
    include LoggingCommon
    include DateTimeCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[remote_repo_url api_key key_scope form title description author contact_email subject]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      dataverse_url = Dataverse::DataverseUrl.parse(remote_repo_url)

      dv_service = Dataverse::DataverseService.new(dataverse_url.dataverse_url)
      if dataverse_url.collection?
        collection = dv_service.find_dataverse_by_id(dataverse_url.collection_id)
        root_dv = collection.data.parents.first
        root_title = root_dv[:name]
        collection_title = collection.data.name
      elsif dataverse_url.dataset?
        dataset = dv_service.find_dataset_version_by_persistent_id(dataverse_url.dataset_id)
        parent_dv = dataset.data.parents.last
        root_dv = dataset.data.parents.first
        root_title = root_dv[:name]
        collection_title = parent_dv[:name]
        dataset_title = dataset.metadata_field('title').to_s
      else
        collection = dv_service.find_dataverse_by_id(':root')
        root_title = collection.data.name
      end

      file_utils = Common::FileUtils.new
      upload_collection = UploadCollection.new.tap do |c|
        c.id = file_utils.normalize_name(File.join(dataverse_url.domain, UploadCollection.generate_code))
        c.name = c.id
        c.project_id = project.id
        c.remote_repo_url = remote_repo_url
        c.type = ConnectorType::DATAVERSE
        c.creation_date = now
        c.metadata = {
          dataverse_url: dataverse_url.dataverse_url,
          dataverse_title: root_title,
          collection_title: collection_title,
          dataset_title: dataset_title,
          collection_id: dataverse_url.collection_id,
          dataset_id: dataverse_url.dataset_id,
        }
      end
      upload_collection.save

      ConnectorResult.new(
        message: { notice: "Upload Collection created: #{upload_collection.name}" },
        success: true
      )
    end

    def edit(collection, request_params)
      case request_params[:form].to_s
      when 'dataset_create'
        Dataverse::Services::DatasetCreate.new.edit(collection, request_params)
      else
        Dataverse::Services::ConnectorEdit.new.edit(collection, request_params)
      end
    end

    def update(collection, request_params)
      case request_params[:form].to_s
      when 'dataset_create'
        Dataverse::Services::DatasetCreate.new.update(collection, request_params)
      else
        Dataverse::Services::ConnectorEdit.new.update(collection, request_params)
      end
    end

  end
end