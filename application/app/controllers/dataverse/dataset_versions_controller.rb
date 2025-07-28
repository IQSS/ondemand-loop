class Dataverse::DatasetVersionsController < ApplicationController
  include LoggingCommon

  before_action :build_dataset_url
  before_action :validate_dataset_url

  def versions
    repo_info = RepoRegistry.repo_db.get(@dataset_url.dataverse_url)
    api_key = repo_info&.metadata&.auth_key
    service = Dataverse::DatasetService.new(@dataset_url.dataverse_url, api_key: api_key)

    versions_response = service.dataset_versions_by_persistent_id(@dataset_url.dataset_id)
    @versions = versions_response&.versions || []
    log_info('Dataset versions', { dataverse_url: @dataset_url.dataverse_url, dataset_id: @dataset_url.dataset_id, versions: @versions.map(&:version) })

    render partial: '/dataverse/datasets/versions', layout: false
  rescue => e
    log_error('Unexpected error', { dataset_url: @dataset_url.dataset_url }, e)
    render json: { error: t('dataverse.datasets.versions.dataverse_service_error', dataverse_url: @dataset_url.dataverse_url, persistent_id: @dataset_url.dataset_id, version: @dataset_url.version) }, status: :internal_server_error
  end

  private

  def build_dataset_url
    domain = params[:dv_hostname]
    scheme = params[:dv_scheme] || "https"
    port = params[:dv_port] || 443
    persistent_id = params[:persistent_id]
    @dataset_url = Dataverse::DataverseUrl.dataset_from_parts(domain, persistent_id, scheme: scheme, port: port)
    if @dataset_url.nil?
      render json: { error: t('dataverse.datasets.versions.invalid_request') }, status: :bad_request
    end
  end

  def validate_dataset_url
    resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    result = resolver.resolve(@dataset_url.dataverse_url)
    if result.type != ConnectorType::DATAVERSE
      render json: { error: t('dataverse.datasets.versions.url_not_supported', dataverse_url: @dataset_url.dataverse_url) }, status: :bad_request
    end
  end
end
