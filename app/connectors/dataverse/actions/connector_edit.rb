module Dataverse::Actions
  class ConnectorEdit
    def edit(upload_bundle, request_params)
      ConnectorResult.new(
        partial: '/connectors/dataverse/connector_edit_form',
        locals: { upload_bundle: upload_bundle }
      )
    end

    def update(upload_bundle, request_params)
      repo_key = request_params[:api_key]
      scope = request_params[:key_scope]
      if scope == 'bundle'
        metadata = upload_bundle.metadata
        metadata[:auth_key] = repo_key
        upload_bundle.update({ metadata: metadata })
      else
        server_domain = upload_bundle.connector_metadata.server_domain
        RepoRegistry.repo_db.update(server_domain, metadata: {auth_key: repo_key})
      end

      ConnectorResult.new(
        message: { notice: I18n.t('connectors.dataverse.actions.connector_edit.message_success', name: upload_bundle.name) },
        success: true
      )
    end
  end
end