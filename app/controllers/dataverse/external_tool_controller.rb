module Dataverse
  class ExternalToolController < ApplicationController
    #Handler for dataset external tool
    def dataset
      callback = params[:callback]
      service = Dataverse::ExternalToolService.new
      service_response = service.process_callback(callback)

      metadata = service_response[:metadata]
      dataset_pid = service_response[:response].data.query_parameters.dataset_pid
      extra_params = {}
      extra_params[:dv_scheme] = "http" if metadata.scheme != "https"
      extra_params[:dv_port] = metadata.port if metadata.port != 443

      redirect_to view_dataverse_dataset_path(metadata.hostname, dataset_pid, extra_params)
    end
  end
end