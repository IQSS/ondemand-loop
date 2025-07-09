class Dataverse::DatasetsController < ApplicationController
  include LoggingCommon
  include Dataverse::CommonHelper

  before_action :get_dv_full_hostname
  before_action :validate_dataverse_url
  before_action :init_service
  before_action :init_project_service, only: [ :download ]
  before_action :find_dataset_by_persistent_id
  before_action :search_files_page

  def show
  end

  def download
    file_ids = params[:file_ids]
    project = Project.find(params[:project_id])
    if project.nil?
      project = @project_service.initialize_project
      unless project.save
        errors = project.errors.full_messages.join(", ")
        redirect_back fallback_location: root_path, alert: t("dataverse.datasets.download.error_generating_project", errors: errors)
        return
      end
    end

    download_files = @project_service.initialize_download_files(project, @dataset, @files_page, file_ids)
    download_files.each do |file|
      unless file.valid?
        errors = file.errors.full_messages.join(", ")
        log_error('DownloadFile validation error', {error: errors, project_id: project.id, file: file.to_s})
        redirect_back fallback_location: root_path, alert: t("dataverse.datasets.download.invalid_file_in_selection", filename: file.filename, errors: errors)
        return
      end
    end

    save_results = download_files.map(&:save)
    if save_results.include?(false)
      redirect_back fallback_location: root_path, alert: t("dataverse.datasets.download.error_generating_the_download_file")
      return
    end

    redirect_back fallback_location: root_path, notice: t("dataverse.datasets.download.files_added_to_project", project_name: project.name)
  end

  private

  def get_dv_full_hostname
    @dataverse_url = current_dataverse_url
  end

  def validate_dataverse_url
    resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = resolver.resolve(@dataverse_url)
    unless result.type == ConnectorType::DATAVERSE
      redirect_to root_path, alert: t('dataverse.datasets.url_not_supported', dataverse_url: @dataverse_url)
      return
    end
  end

  def init_service
    @service = Dataverse::DatasetService.new(@dataverse_url)
  end

  def init_project_service
    @project_service = Dataverse::ProjectService.new(@dataverse_url)
  end

  def find_dataset_by_persistent_id
    @persistent_id = params[:persistent_id]
    begin
      @dataset = @service.find_dataset_version_by_persistent_id(@persistent_id)
      unless @dataset
        log_error('Dataset not found.', { dataverse: @dataverse_url, persistent_id: @persistent_id })
        redirect_back_to_app(alert: t("dataverse.datasets.dataset_not_found", dataverse_url: @dataverse_url, persistent_id: @persistent_id))
        return
      end
    rescue Dataverse::DatasetService::UnauthorizedException => e
      log_error('Dataset requires authorization', { dataverse: @dataverse_url, persistent_id: @persistent_id }, e)
      redirect_back_to_app(alert: t("dataverse.datasets.dataset_requires_authorization", dataverse_url: @dataverse_url, persistent_id: @persistent_id))
    rescue => e
      log_error('Dataverse service error', { dataverse: @dataverse_url, persistent_id: @persistent_id }, e)
      redirect_back_to_app(alert: t("dataverse.datasets.dataverse_service_error", dataverse_url: @dataverse_url, persistent_id: @persistent_id))
      return
    end
  end

  def search_files_page
    @page = params[:page] ? params[:page].to_i : 1
    @search_query = params[:query].present? ? ActionView::Base.full_sanitizer.sanitize(params[:query]) : nil
    begin
      @files_page = @service.search_dataset_files_by_persistent_id(@persistent_id, page: @page, per_page: 10, query: @search_query)
      unless @files_page
        log_error('Dataset files not found.', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page})
        flash[:alert] = t("dataverse.datasets.dataset_files_not_found", dataverse_url: @dataverse_url, persistent_id: @persistent_id, page: @page)
        redirect_to root_path
        return
      end
    rescue Dataverse::DatasetService::UnauthorizedException => e
      log_error('Dataset files endpoint requires authorization', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page}, e)
      flash[:alert] = t("dataverse.datasets.dataset_files_endpoint_requires_authorization", dataverse_url: @dataverse_url, persistent_id: @persistent_id, page: @page)
      redirect_to root_path
    rescue Exception => e
      log_error('Dataverse service error while searching files', {dataverse: @dataverse_url, persistent_id: @persistent_id, page: @page}, e)
      flash[:alert] = t("dataverse.datasets.dataverse_service_error_searching_files", dataverse_url: @dataverse_url, persistent_id: @persistent_id, page: @page)
      redirect_to root_path
      return
    end
  end

  def redirect_back_to_app(fallback: root_path, **options)
    if redirect_back?
      redirect_back(fallback_location: fallback, **options)
    else
      redirect_to(fallback, **options)
    end
  end

  def redirect_back?
    return false unless request.referer

    begin
      referer_uri = URI.parse(request.referer)
    rescue URI::InvalidURIError
      return false
    end

    return true if referer_uri.host == request.host
    return false unless request.script_name
    return referer_uri.path.start_with?(request.script_name)
  end

end
