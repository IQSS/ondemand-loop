module Zenodo
  class ExploreConnectorProcessor
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def params_schema
      [
        :connector_type, :object_type, :object_id,
        :query, :page,
        :project_id, { file_ids: [] }
      ]
    end

    def show(request_params)
      explorer = load_explorer(request_params)
      explorer.show(request_params)
    end

    def create(request_params)
      explorer = load_explorer(request_params)
      explorer.create(request_params)
    end

    def landing(_request_params)
      ConnectorResult.new(
        message: { alert: I18n.t('connectors.zenodo.actions.landing.message_action_not_supported') },
        success: false
      )
    end

    private

    def load_explorer(request_params)
      ConnectorActionDispatcher.explorer(request_params[:connector_type], request_params[:object_type], request_params[:object_id])
    end
  end
end
