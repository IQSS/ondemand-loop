# frozen_string_literal: true

module Zenodo
  class UploadBundleConnectorProcessor
    include LoggingCommon

    # Needed to implement expected interface in ConnectorClassDispatcher
    def initialize(object = nil); end

    def params_schema
      %i[remote_repo_url form api_key key_scope title upload_type description creators deposition_id]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Zenodo::ZenodoUrl.parse(remote_repo_url)

      case
      when url_data.record?
        Zenodo::Handlers::UploadBundleCreateFromRecord.new.create(project, request_params)
      when url_data.deposition?
        Zenodo::Handlers::UploadBundleCreateFromDeposition.new.create(project, request_params)
      else
        Zenodo::Handlers::UploadBundleCreateFromServer.new.create(project, request_params)
      end

    rescue => e
      log_error('UploadBundle creation error', { remote_repo_url: remote_repo_url }, e)
      return error(I18n.t('connectors.zenodo.upload_bundle_connector_processor.message_create_error', url: remote_repo_url))
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

    rescue => e
      log_error('UploadBundle edit error', { bundle_id: upload_bundle.id, form: request_params[:form] }, e)
      return error(I18n.t('connectors.zenodo.upload_bundle_connector_processor.message_edit_error', url: upload_bundle.remote_repo_url))
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

    rescue => e
      log_error('UploadBundle update error', { bundle_id: upload_bundle.id, form: request_params[:form] }, e)
      return error(I18n.t('connectors.zenodo.upload_bundle_connector_processor.message_update_error', url: upload_bundle.remote_repo_url))
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
