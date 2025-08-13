# frozen_string_literal: true

# Concern with helper methods for controllers that resolve connectors and
# repository URLs. It parses the connector type from params, builds a repo URL
# from request parameters, and validates the resolved repository type against
# the connector type.

module ConnectorResolver
  extend ActiveSupport::Concern

  private

  def parse_connector_type
    @connector_type = ConnectorType.get(params[:connector_type])
  rescue ArgumentError => e
    log_error('Invalid connector type', { connector_type: params[:connector_type] }, e)
    redirect_to root_path, alert: I18n.t('connector_resolver.message_invalid_connector_type', connector_type: params[:connector_type])
  end

  def build_repo_url
    @repo_url = Repo::RepoUrl.build(
      params[:server_domain],
      scheme: params[:server_scheme],
      port: params[:server_port]
    )

    if @repo_url.nil?
      redirect_to root_path, alert: I18n.t('connector_resolver.message_invalid_repo_url', repo_url: '')
    end
  end

  def validate_repo_url
    repo_resolver = Repo::RepoResolverService.new(RepoRegistry.resolvers)
    resolution = repo_resolver.resolve(@repo_url.to_s)
    if resolution.type != @connector_type
      redirect_to root_path, alert: I18n.t('connector_resolver.message_invalid_repo_url', repo_url: @repo_url.to_s)
    end
  end
end
