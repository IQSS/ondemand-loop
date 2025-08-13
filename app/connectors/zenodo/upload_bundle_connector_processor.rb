# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorProcessor
    def initialize(object = nil); end

    def params_schema
      %i[remote_repo_url form api_key key_scope]
    end

    def create(project, request_params)
      Zenodo::Handlers::UploadBundleCreate.new.create(project, request_params)
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(template: '/connectors/zenodo/connector_edit_form', locals: { upload_bundle: upload_bundle })
    end

    def update(upload_bundle, request_params)
      case request_params[:form].to_s
      when 'deposition_fetch'
        Zenodo::Handlers::DepositionFetch.new.update(upload_bundle, request_params)
      else
        Zenodo::Handlers::ConnectorEdit.new.update(upload_bundle, request_params)
      end
    end

  end
end
