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
      api_key = connector_metadata.api_key.value

      if connector_metadata.deposition_id.present?
        deposition_service = Zenodo::DepositionService.new(connector_metadata.zenodo_url, api_key: api_key)
        deposition = deposition_service.find_deposition(connector_metadata.deposition_id)
      else
        record_service = Zenodo::RecordService.new(connector_metadata.zenodo_url)
        deposition = record_service.get_or_create_deposition(
          connector_metadata.record_id,
          api_key: api_key,
          concept_id: connector_metadata.concept_id
        )
      end

      return error(I18n.t('connectors.zenodo.actions.fetch_deposition.message_deposition_not_found', url: upload_bundle.repo_url)) unless deposition

      connector_metadata.title = deposition.title
      connector_metadata.bucket_url = deposition.bucket_url
      connector_metadata.deposition_id ||= deposition.id.to_s
      connector_metadata.draft = deposition.draft?
      upload_bundle.update({ metadata: connector_metadata.to_h })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.actions.fetch_deposition.message_success', name: deposition.title) },
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