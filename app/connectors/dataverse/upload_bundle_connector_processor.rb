# frozen_string_literal: true

module Dataverse
  # Dataverse upload batch connector processor. Responsible for managing updates to collections of type Dataverse
  class UploadBundleConnectorProcessor
    include LoggingCommon
    include DateTimeCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      %i[remote_repo_url form active_tab api_key key_scope collection_id dataset_id title description author contact_email subject]
    end

    def create(project, request_params)
      Dataverse::Handlers::UploadBundleCreate.new.create(project, request_params)
    end

    def edit(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Dataverse::Handlers::DatasetFormTabs.new.edit(upload_bundle, request_params)
      when 'dataset_create'
        Dataverse::Handlers::DatasetCreate.new.edit(upload_bundle, request_params)
      when 'dataset_select'
        Dataverse::Handlers::DatasetSelect.new.edit(upload_bundle, request_params)
      when 'collection_select'
        Dataverse::Handlers::CollectionSelect.new.edit(upload_bundle, request_params)
      else
        Dataverse::Handlers::ConnectorEdit.new.edit(upload_bundle, request_params)
      end
    end

    def update(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Dataverse::Handlers::DatasetFormTabs.new.update(upload_bundle, request_params)
      when 'dataset_create'
        Dataverse::Handlers::DatasetCreate.new.update(upload_bundle, request_params)
      when 'dataset_select'
        Dataverse::Handlers::DatasetSelect.new.update(upload_bundle, request_params)
      when 'collection_select'
        Dataverse::Handlers::CollectionSelect.new.update(upload_bundle, request_params)
      else
        Dataverse::Handlers::ConnectorEdit.new.update(upload_bundle, request_params)
      end
    end

  end
end