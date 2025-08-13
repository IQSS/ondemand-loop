module Zenodo::Handlers
  class DepositionCreate
    include LoggingCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      %i[title upload_type description creators]
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(
        template: '/connectors/zenodo/deposition_create_form',
        locals: { upload_bundle: upload_bundle }
      )
    end

    def update(upload_bundle, request_params)
      connector_metadata = upload_bundle.connector_metadata
      api_key = connector_metadata.api_key.value
      log_info('Creating deposition', { upload_bundle: upload_bundle.id })

      creators = parse_creators(request_params[:creators])
      request = Zenodo::CreateDepositionRequest.new(
        title: request_params[:title],
        upload_type: request_params[:upload_type],
        description: request_params[:description],
        creators: creators
      )

      service = Zenodo::DepositionService.new(connector_metadata.zenodo_url, api_key: api_key)
      response = service.create_deposition(request)

      metadata = upload_bundle.metadata
      metadata[:deposition_id] = response.id.to_s
      metadata[:title] = request.title
      metadata[:bucket_url] = response.bucket_url
      metadata[:draft] = response.editable?
      upload_bundle.update({ metadata: metadata })
      log_info('Deposition created', { upload_bundle: upload_bundle.id, deposition_id: response.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.handlers.deposition_create.message_success', id: response.id, title: request.title) },
        success: true
      )
    rescue Zenodo::ApiService::UnauthorizedException => e
      log_error('Auth error creating deposition', { upload_bundle: upload_bundle.id }, e)
      ConnectorResult.new(
        message: { alert: I18n.t('connectors.zenodo.handlers.deposition_create.message_auth_error') },
        success: false
      )
    end

    private

    def parse_creators(value)
      return [] unless value.present?
      value.split(';').map { |name| { name: name.strip } }
    end

  end
end
