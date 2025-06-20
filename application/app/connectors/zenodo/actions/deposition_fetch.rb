module Zenodo::Actions
  class DepositionFetch
    include LoggingCommon
    include DateTimeCommon

    def edit(upload_bundle, request_params)
      raise NotImplementedError, 'Only update is supported for DepositionFetch'
    end

    def update(upload_bundle, request_params)
      connector_metadata = upload_bundle.connector_metadata
      connector_metadata.api_key
      deposition_service = Zenodo::DepositionService.new(connector_metadata.zenodo_url, api_key: connector_metadata.api_key.value)
      deposition = deposition_service.find_deposition(connector_metadata.deposition_id)
      return error(I18n.t('connectors.zenodo.actions.fetch_deposition.message_deposition_not_found', repo_url: upload_bundle.repo_url)) unless deposition

      connector_metadata.title = deposition.title
      connector_metadata.bucket_url = deposition.bucket_url
      connector_metadata.draft = deposition.draft?
      upload_bundle.update({ metadata: connector_metadata.to_h })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.actions.fetch_deposition.message_success', title: deposition.title) },
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