# frozen_string_literal: true

module Zenodo
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zurl = Zenodo::ZenodoUrl.parse(object_url)
      if zurl.record?
        redirect_url = @url_helper.view_zenodo_record_path(zurl.record_id)
      else
        message = { alert: I18n.t('connectors.zenodo.display_repo_controller.message_url_not_supported', url: object_url) }
        redirect_url = @url_helper.view_zenodo_landing_path
      end

      ConnectorResult.new(
        redirect_url: redirect_url,
        message: message,
        success: true
      )
    end
  end
end
