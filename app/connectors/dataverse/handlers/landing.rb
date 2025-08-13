module Dataverse::Handlers
  class Landing
    include LoggingCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      [
        :page,
        :query
      ]
    end

    def show(request_params)
      begin
        hub_registry = DataverseHubRegistry.registry
        installations = hub_registry.installations
        page = request_params[:page] ? request_params[:page].to_i : 1
        installations_page = Page.new(installations, page, ::Configuration.default_pagination_items,
                                      query: request_params[:query], filter_by: :name)
        ConnectorResult.new(
          template: '/connectors/dataverse/landing/index',
          locals: { installations_page: installations_page },
          success: true
        )
      rescue => e
        log_error('Dataverse Installations service error', {}, e)
        ConnectorResult.new(
          message: { alert: I18n.t('dataverse.landing.index.dataverse_installations_service_error') },
          success: false
        )
      end
    end
  end
end

