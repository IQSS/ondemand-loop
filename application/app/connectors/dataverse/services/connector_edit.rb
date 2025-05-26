module Dataverse::Services
  class ConnectorEdit
    def edit(collection, request_params)
      ConnectorResult.new(
        partial: '/connectors/dataverse/connector_edit_form',
        locals: { collection: collection },
        message: { notice: "Loaded connector form" }
      )
    end

    def update(collection, request_params)
      sleep(10)
      repo_key = request_params[:api_key]
      scope = request_params[:key_scope]
      if scope == 'collection'
        metadata = collection.metadata
        metadata[:api_key] = repo_key
        collection.update({ metadata: metadata })
      else
        server_domain = collection.connector_metadata.server_domain
        RepoRegistry.repo_db.update(server_domain, metadata: {api_key: repo_key})
      end

      ConnectorResult.new(
        message: { notice: "API Key updated: #{collection.name}" },
        success: true
      )
    end
  end
end