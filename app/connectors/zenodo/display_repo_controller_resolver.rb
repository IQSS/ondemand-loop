# frozen_string_literal: true

module Zenodo
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      zurl = Zenodo::ZenodoUrl.parse(object_url)
      redirect_url = if zurl.record?
                        @url_helper.view_zenodo_record_path(zurl.record_id)
                      else
                        view_zenodo_landing_path
                      end
      ConnectorResult.new(redirect_url: redirect_url, success: true)
    end
  end
end
