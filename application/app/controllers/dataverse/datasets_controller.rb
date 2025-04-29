class Dataverse::DatasetsController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  before_action :get_dv_full_hostname
  before_action :init_service
  before_action :find_dataset_by_persistent_id
  before_action :search_files_page

  def show
  end

  def download
    file_ids = params[:file_ids]
    @download_collection = @service.initialize_download_collection(@dataset)
    unless @download_collection.save
      flash[:error] = "Error generating the download collection: #{@download_collection.errors}"
      redirect_to downloads_path
      return
    end
    @download_files = @service.initialize_download_files(@download_collection, @files_page, file_ids)
    save_results = @download_files.each.map { |download_file| download_file.save }
    if save_results.include?(false)
      flash[:error] = "Error generating the download file"
    end
    redirect_to downloads_path
  end

  private

  def get_dv_full_hostname
    @dataverse_url = current_dataverse_url
  end

  def init_service
    @service = Dataverse::DataverseService.new(@dataverse_url)
  end

  def find_dataset_by_persistent_id
    @persistent_id = params[:persistent_id]
    begin
      @dataset = @service.find_dataset_version_by_persistent_id(@persistent_id)
      unless @dataset
        log_error('Dataset not found.', {dataverse: @dataverse_url, persistent_id: @persistent_id})
        flash[:error] = "Dataset not found. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id}"
        redirect_to root_path
        return
      end
    rescue Dataverse::DataverseService::UnauthorizedException => e
      log_error('Dataset requires authorization', {dataverse: @dataverse_url, persistent_id: @persistent_id}, e)
      flash[:error] = "Dataset requires authorization. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id}"
      redirect_to root_path
    rescue Exception => e
      log_error('Dataverse service error', {dataverse: @dataverse_url, persistent_id: @persistent_id}, e)
      flash[:error] = "Dataverse service error. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id}"
      redirect_to root_path
      return
    end
  end

  def search_files_page
    @page = params[:page] ? params[:page].to_i : 1
    begin
      @files_page = @service.search_dataset_files_by_persistent_id(@persistent_id, page: @page, per_page: 10)
      unless @files_page
        log_error('Dataset files not found.', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page})
        flash[:error] = "Dataset files not found. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id} page: #{@page}"
        redirect_to root_path
        return
      end
    rescue Dataverse::DataverseService::UnauthorizedException => e
      log_error('Dataset files endpoint requires authorization', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page}, e)
      flash[:error] = "Dataset files endpoint requires authorization. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id} page: #{@page}"
      redirect_to root_path
    rescue Exception => e
      log_error('Dataverse service error while searching files', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page}, e)
      flash[:error] = "Dataverse service error while searching files. Dataverse: #{@dataverse_url} persistentId: #{@persistent_id} page: #{@page}"
      redirect_to root_path
      return
    end
  end
end
