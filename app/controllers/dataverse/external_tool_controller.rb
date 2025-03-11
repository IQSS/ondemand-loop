module Dataverse
  class ExternalToolController < ApplicationController
    #Handler for dataset external tool
    def dataset
      callback = params[:callback]
      service = Dataverse::ExternalToolService.new
      service_response = service.process_callback(callback)

      # TODO redirect to the Dataset view
      render json: service_response
    end
  end
end