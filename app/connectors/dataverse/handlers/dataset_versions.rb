module Dataverse::Handlers
  class DatasetVersions
    include LoggingCommon

    def initialize(object_id = nil)
      @persistent_id = object_id
    end

    def params_schema
      [
        :repo_url
      ]
    end

    def show(request_params)
      repo_url = request_params[:repo_url]
      dataverse_url = repo_url.server_url

      repo_info = ::Configuration.repo_db.get(dataverse_url)
      api_key = repo_info&.metadata&.auth_key
      service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)

      versions_response = service.dataset_versions_by_persistent_id(@persistent_id)
      versions = versions_response&.versions || []
      log_info('Dataset versions', { dataverse_url: dataverse_url, dataset_id: @persistent_id, versions: versions.map(&:version) })

      ConnectorResult.new(
        template: '/connectors/dataverse/dataset_versions/show',
        locals: { repo_url: repo_url, dataset_id: @persistent_id, versions: versions },
        success: true
      )
    end
  end
end

