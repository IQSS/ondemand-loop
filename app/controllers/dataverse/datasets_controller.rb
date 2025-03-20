class Dataverse::DatasetsController < ApplicationController
  before_action :find_dataverse_metadata
  before_action :find_dataset

  def show
  end

  def download
    @file_ids = params[:file_ids]
    render json: @file_ids
  end

  private

  def find_dataverse_metadata
    @dataverse_metadata = Dataverse::DataverseMetadata.find(params[:metadata_id])
    unless @dataverse_metadata
      flash[:error] = "Dataverse host metadata not found"
      redirect_to root_path
      return
    end
  end

  def find_dataset
    begin
      service = Dataverse::DataverseService.new(@dataverse_metadata)
      @dataset = service.find_dataset_by_id(params[:id])
      unless @dataset
        flash[:error] = "Dataset not found"
        redirect_to root_path
        return
      end
    rescue Exception => e
      Rails.logger.error("Dataverse service error: #{e.message}")
      flash[:error] = "An error occurred while retrieving the dataset #{params[:id]}"
      redirect_to root_path
      return
    end
  end
end
