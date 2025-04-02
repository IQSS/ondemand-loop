module Dataverse
  class ExternalToolController < ApplicationController
    #Handler for dataset external tool
    def dataset
      callback = params[:callback]
      service = Dataverse::ExternalToolService.new
      service_response = service.process_callback(callback)

      metadata_id = service_response[:metadata].id
      dataset_pid = service_response[:response].data.query_parameters.dataset_pid

      redirect_to view_dataverse_dataset_path(metadata_id, dataset_pid)
    end
  end
end