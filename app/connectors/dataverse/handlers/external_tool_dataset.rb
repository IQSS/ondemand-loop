# frozen_string_literal: true

module Dataverse::Handlers
  class ExternalToolDataset
    include LoggingCommon
    include ExploreHelper
    include Rails.application.routes.url_helpers

    PERMITTED_PARAMS = [:dataverse_url, :dataset_id, :version, :locale].freeze

    def initialize(object_id = nil)
      # no object id required
    end

    def params_schema
      PERMITTED_PARAMS
    end

    def show(request_params)
      external_tool_data = request_params.with_indifferent_access
      dataverse_url = Dataverse::DataverseUrl.parse(external_tool_data[:dataverse_url])
      dataset_id = external_tool_data[:dataset_id]
      if dataverse_url.nil? || dataset_id.blank?
        log_error('Invalid external tool request', { params: external_tool_data })
        return ConnectorResult.new(
          message: { alert: I18n.t('connectors.dataverse.external_tool_dataset.show.invalid_request_error') },
          success: false
        )
      end

      log_info('External tool request completed', { params: external_tool_data })
      redirect_url = link_to_explore(
        ConnectorType::DATAVERSE,
        dataverse_url,
        type: 'datasets',
        id: dataset_id,
        version: external_tool_data[:version]
      )

      ConnectorResult.new(
        redirect_url: redirect_url,
        success: true
      )
    end
  end
end
