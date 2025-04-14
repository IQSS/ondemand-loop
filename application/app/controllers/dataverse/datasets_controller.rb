class Dataverse::DatasetsController < ApplicationController
  include LoggingCommon

  before_action :get_dv_full_hostname
  before_action :init_service
  before_action :find_dataset_by_persistent_id

  def show
    @files = @dataset.files
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

  def get_dv_full_hostname
    if params[:dataverse_url]
      @dataverse_url =  URI.parse(params[:dataverse_url]).to_s
    elsif params[:dv_hostname]
      hostname = params[:dv_hostname]
      scheme = params[:dv_scheme] || "https"
      port = params[:dv_port] || 443
      @dataverse_url = URI.parse(scheme + "://" + hostname + ":" + port.to_s).to_s
    else
      flash[:error] = "Invalid Dataverse Hostname"
      redirect_to downloads_path
      return
    end
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_url)
  end

  def find_dataset_by_persistent_id
    @persistent_id = params[:persistent_id]
    begin
      @dataset = @service.find_dataset_by_persistent_id(@persistent_id)
      unless @dataset
        log_error('Dataset not found.', {dataverse: @dataverse_url, persistent_id: @persistent_id})
        flash[:error] = "Dataset not found. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id}"
        redirect_to downloads_path
        return
      end
    rescue Exception => e
      log_error('Dataverse service error', {dataverse: @dataverse_url, persistent_id: @persistent_id}, e)
      flash[:error] = "Dataverse service error. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id}"
      redirect_to downloads_path
      return
    end
  end

end
