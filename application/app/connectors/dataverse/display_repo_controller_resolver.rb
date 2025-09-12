# frozen_string_literal: true

module Dataverse
  # Dataverse controller resolver to parse URLs and redirect to the relevant Dataverse controller to display the data.
  class DisplayRepoControllerResolver
    include LoggingCommon
    include ExploreHelper
    include Rails.application.routes.url_helpers

    def initialize(object = nil)
      # Needed to implement expected interface in ConnectorClassDispatcher
    end

    def get_controller_url(object_url)
      dataverse_url = Dataverse::DataverseUrl.parse(object_url)
      message = nil

      if dataverse_url.nil?
        redirect_url = link_to_landing(ConnectorType::DATAVERSE)
      elsif dataverse_url.dataverse? || (dataverse_url.file? && dataverse_url.dataset_id.nil?)
        redirect_url = link_to_explore(ConnectorType::DATAVERSE, dataverse_url, type: 'collections', id: ':root')
      elsif dataverse_url.collection?
        redirect_url = link_to_explore(ConnectorType::DATAVERSE, dataverse_url, type: 'collections', id: dataverse_url.collection_id)
      elsif dataverse_url.dataset? || dataverse_url.file?
        params = {}
        params[:version] = dataverse_url.version if dataverse_url.version
        redirect_url = link_to_explore(ConnectorType::DATAVERSE, dataverse_url, type: 'datasets', id: dataverse_url.dataset_id, **params)
      else
        redirect_url = link_to_landing(ConnectorType::DATAVERSE)
        message = { alert: I18n.t('connectors.dataverse.display_repo_controller.message_url_not_supported', url: object_url) }
      end

      ConnectorResult.new(
        redirect_url: redirect_url,
        message: message,
        success: true,
        )
    end

  end

end
