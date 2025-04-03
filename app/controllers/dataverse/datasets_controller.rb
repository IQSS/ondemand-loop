class Dataverse::DatasetsController < ApplicationController
  before_action :find_dataverse_metadata
  before_action :init_service
  before_action :find_dataset

  def show
    @files = @dataset.data.latest_version.files
  end

  def download
    file_ids = params[:file_ids]
    @download_collection = @service.initialize_download_collection(@dataset)
    unless @download_collection.save
      flash[:error] = "Error generating the download collection: #{@download_collection.errors}"
      redirect_to downloads_path
      return
    end
    @download_files = @service.initialize_download_files(@download_collection, @dataset, file_ids)
    save_results = @download_files.each.map { |download_file| download_file.save }
    if save_results.include?(false)
      flash[:error] = "Error generating the download file"
    end
    redirect_to downloads_path
  end

  private

  def find_dataverse_metadata
    @dataverse_metadata = Dataverse::DataverseMetadata.find(params[:metadata_id])
    unless @dataverse_metadata
      flash[:error] = "Dataverse host metadata not found"
      redirect_to downloads_path
      return
    end
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_metadata)
  end

  def find_dataset
    begin
      @dataset = @service.find_dataset_by_id(params[:id])
      unless @dataset
        flash[:error] = "Dataset not found"
        redirect_to downloads_path
        return
      end
    rescue Exception => e
      Rails.logger.error("Dataverse service error: #{e.message}")
      flash[:error] = "An error occurred while retrieving the dataset #{params[:id]}"
      redirect_to downloads_path
      return
    end
  end

end
