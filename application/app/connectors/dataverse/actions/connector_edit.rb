module Dataverse::Actions
  class ConnectorEdit
    def edit(upload_batch, request_params)
      ConnectorResult.new(
        partial: '/connectors/dataverse/connector_edit_form',
        locals: { upload_batch: upload_batch }
      )
    end

    def update(upload_batch, request_params)
      repo_key = request_params[:api_key]
      scope = request_params[:key_scope]
      if scope == 'collection'
        metadata = upload_batch.metadata
        metadata[:api_key] = repo_key
        upload_batch.update({ metadata: metadata })
      else
        server_domain = upload_batch.connector_metadata.server_domain
        RepoRegistry.repo_db.update(server_domain, metadata: {api_key: repo_key})
      end

      ConnectorResult.new(
        redirect_url: Rails.application.routes.url_helpers.project_path(id: upload_batch.project_id, anchor: "tab-#{upload_batch.id}"),
        message: { notice: I18n.t('connectors.dataverse.actions.connector_edit.success', name: upload_batch.name) },
        success: true
      )
    end
  end
end