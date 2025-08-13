# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorProcessor
    def initialize(object = nil); end

    def params_schema
      %i[remote_repo_url form api_key key_scope title upload_type description creators deposition_id]
    end

    def create(project, request_params)
      Zenodo::Handlers::UploadBundleCreate.new.create(project, request_params)
    end

    def edit(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'dataset_form_tabs'
        Zenodo::Handlers::DatasetFormTabs.new.edit(upload_bundle, request_params)
      when 'deposition_create'
        Zenodo::Handlers::DepositionCreate.new.edit(upload_bundle, request_params)
      else
        Zenodo::Handlers::ConnectorEdit.new.edit(upload_bundle, request_params)
      end
    end

    def update(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'deposition_fetch'
        Zenodo::Handlers::DepositionFetch.new.update(upload_bundle, request_params)
      when 'deposition_create'
        Zenodo::Handlers::DepositionCreate.new.update(upload_bundle, request_params)
      when 'dataset_select'
        Zenodo::Handlers::DatasetSelect.new.update(upload_bundle, request_params)
      when 'dataset_form_tabs'
        Zenodo::Handlers::DatasetFormTabs.new.update(upload_bundle, request_params)
      else
        Zenodo::Handlers::ConnectorEdit.new.update(upload_bundle, request_params)
      end
    end

  end
end
