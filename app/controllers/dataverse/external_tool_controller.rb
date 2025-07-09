# frozen_string_literal: true

module Dataverse
  class ExternalToolController < ApplicationController
    include LoggingCommon

    PERMITTED_PARAMS = [:dataverse_url, :dataset_id, :version, :locale]

    def dataset
      external_tool_data = external_tool_params
      dataverse_url = Dataverse::DataverseUrl.parse(external_tool_data[:dataverse_url])
      dataset_id = external_tool_data[:dataset_id]
      if dataverse_url.nil? || dataset_id.blank?
        log_error('Invalid external tool request', { params: external_tool_data })
        redirect_to root_path, alert: t('.invalid_request_error')
        return
      end

      dataverse_overrides = {}
      dataverse_overrides[:dv_scheme] = dataverse_url.scheme_override
      dataverse_overrides[:dv_port] = dataverse_url.port

      log_info('External tool request completed', { params: external_tool_data })
      redirect_to view_dataverse_dataset_path(dataverse_url.domain, dataset_id, dataverse_overrides)
    end

    private

    def external_tool_params
      params.permit(*PERMITTED_PARAMS)
    end
  end
end