module Dataverse
  class ExternalToolController < ApplicationController
    #Handler for dataset external tool
    def dataset
      callback = params[:callback]
      service = Dataverse::ExternalToolService.new
      service_response = service.process_callback(callback)

      dataverse_uri = service_response[:dataverse_uri]
      dataset_pid = service_response[:response].data.query_parameters.dataset_pid
      extra_params = {}
      extra_params[:dv_scheme] = "http" if dataverse_uri.scheme != "https"
      extra_params[:dv_port] = dataverse_uri.port if dataverse_uri.port != 443

      redirect_to view_dataverse_dataset_path(dataverse_uri.hostname, dataset_pid, extra_params)
    end
  end
end