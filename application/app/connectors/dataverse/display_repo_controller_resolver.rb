# frozen_string_literal: true

module Dataverse
  # Dataverse controller resolver to parse URLs and redirect to the relevant Dataverse controller to display the data.
  class DisplayRepoControllerResolver
    include LoggingCommon

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
      @url_helper = Rails.application.routes.url_helpers
    end

    def get_controller_url(object_url)
      dataverse_url = Dataverse::DataverseUrl.parse(object_url)
      if dataverse_url.nil?
        redirect_url = @url_helper.view_dataverse_landing_path
      elsif dataverse_url.dataverse? || (dataverse_url.file? && dataverse_url.dataset_id.nil?)
        redirect_url = @url_helper.view_dataverse_path(dataverse_url.domain, ':root', dv_scheme: dataverse_url.scheme_override, dv_port: dataverse_url.port)
      elsif dataverse_url.collection?
        redirect_url = @url_helper.view_dataverse_path(dataverse_url.domain, dataverse_url.collection_id, dv_scheme: dataverse_url.scheme_override, dv_port: dataverse_url.port)
      elsif dataverse_url.dataset? || dataverse_url.file?
        redirect_url = @url_helper.view_dataverse_dataset_path(
          dv_hostname: dataverse_url.domain,
          persistent_id: dataverse_url.dataset_id,
          dv_scheme: dataverse_url.scheme_override,
          dv_port: dataverse_url.port,
          version: dataverse_url.version
        )
      else
        redirect_url = @url_helper.view_dataverse_landing_path
      end

      ConnectorResult.new(
        redirect_url: redirect_url,
        success: true,
        )
    end

  end

end