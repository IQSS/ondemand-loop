module Dataverse::Handlers
  class ConnectorEdit
    include LoggingCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      [
        :api_key,
        :key_scope
      ]
    end

    def edit(upload_bundle, request_params)
      ConnectorResult.new(
        template: '/connectors/dataverse/connector_edit_form',
        locals: { upload_bundle: upload_bundle }
      )
    end

    def update(upload_bundle, request_params)
      repo_key = request_params[:api_key]
      scope = request_params[:key_scope]
      log_info('Updating API key', { upload_bundle: upload_bundle.id, scope: scope })
      if scope == 'bundle'
        metadata = upload_bundle.metadata
        metadata[:auth_key] = repo_key
        upload_bundle.update({ metadata: metadata })
      else
        dataverse_url = upload_bundle.connector_metadata.dataverse_url
        ::Configuration.repo_db.update(dataverse_url, metadata: {auth_key: repo_key})
      end

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.handlers.connector_edit.message_success', name: upload_bundle.name) },
        success: true
      )
    end
  end
end
