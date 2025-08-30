# frozen_string_literal: true

module Zenodo
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zenodo_url = Zenodo::ZenodoUrl.parse(object_url)
      message = nil

      if zenodo_url&.record?
        server_domain = zenodo_url.domain
        object_type = 'records'
        object_id = zenodo_url.record_id
      elsif zenodo_url&.deposition?
        server_domain = zenodo_url.domain
        object_type = 'depositions'
        object_id = zenodo_url.deposition_id
      else
        server_domain =  zenodo_url.domain
        object_type = 'landing'
        object_id = ':root'
        if zenodo_url&.unknown?
          message = { alert: I18n.t('connectors.zenodo.display_repo_controller.message_url_not_supported', url: object_url) }
        end
      end

      connector_type = ConnectorType::ZENODO.to_s

      redirect_url = @url_helper.explore_path(
        connector_type: connector_type,
        server_domain: server_domain,
        object_type: object_type,
        object_id: object_id,
        server_scheme: zenodo_url&.scheme_override,
        server_port: zenodo_url&.port_override
      )

      ConnectorResult.new(
        redirect_url: redirect_url,
        message: message,
        success: true
      )
    end
  end
end
