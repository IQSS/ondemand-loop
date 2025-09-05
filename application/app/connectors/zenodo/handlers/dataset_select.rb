module Zenodo::Handlers
  class DatasetSelect
    include LoggingCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [
        :deposition_id
      ]
    end

    def edit(upload_bundle, request_params)
      raise NotImplementedError, 'Only update is supported for DatasetSelect'
    end

    def update(upload_bundle, request_params)
      deposition_id = request_params[:deposition_id]
      connector_metadata = upload_bundle.connector_metadata
      api_key = connector_metadata.api_key.value
      service = Zenodo::DepositionService.new(connector_metadata.zenodo_url, api_key: api_key)
      deposition = service.find_deposition(deposition_id)
      return error(I18n.t('connectors.zenodo.handlers.deposition_fetch.message_deposition_not_found', url: upload_bundle.repo_url)) unless deposition

      metadata = upload_bundle.metadata
      if deposition.draft?
        metadata[:deposition_id] = deposition.id
        metadata.delete(:record_id)
      else
        metadata[:record_id] = deposition.record_id
        metadata.delete(:deposition_id)
      end
      metadata[:title] = deposition.title
      metadata[:bucket_url] = deposition.bucket_url
      metadata[:draft] = deposition.draft?
      upload_bundle.update({ metadata: metadata })
      log_info('Dataset selected', { upload_bundle: upload_bundle.id, deposition_id: deposition.id, record_id: deposition.record_id })

      ::Configuration.repo_history.add_repo(
        upload_bundle.connector_metadata.title_url,
        ConnectorType::ZENODO,
        title: deposition.title,
        note: deposition.version
      )

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.zenodo.handlers.dataset_select.message_success', title: deposition.title) },
        resource: deposition,
        success: true
      )
    rescue Zenodo::ApiService::UnauthorizedException => e
      log_error('Auth error selecting deposition', { upload_bundle: upload_bundle.id, deposition_id: deposition_id }, e)
      error(I18n.t('connectors.zenodo.handlers.deposition_create.message_auth_error'))
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
