# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorProcessor
    def initialize(object = nil); end

    def params_schema
      %i[remote_repo_url api_key key_scope dataset_id]
    end

    def create(project, request_params)
      Zenodo::Actions::UploadBundleCreate.new.create(project, request_params)
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(partial: '/connectors/zenodo/connector_edit_form', locals: { upload_bundle: upload_bundle })
    end

    def update(upload_bundle, request_params)
      Zenodo::Actions::ConnectorEdit.new.update(upload_bundle, request_params)
    end
  end
end
