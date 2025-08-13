module Dataverse::Handlers
  class Datasets
    include LoggingCommon

    def initialize(object_id = nil)
      @persistent_id = object_id
    end

    def params_schema
      [
        :repo_url,
        :version,
        :page,
        :query,
        :project_id,
        { file_ids: [] }
      ]
    end

    def show(request_params)
      repo_url = request_params[:repo_url]
      dataverse_url = repo_url.server_url
      version = request_params[:version]
      page = request_params[:page] ? request_params[:page].to_i : 1
      search_query = request_params[:query].present? ? ActionView::Base.full_sanitizer.sanitize(request_params[:query]) : nil
      repo_info = RepoRegistry.repo_db.get(dataverse_url)
      api_key = repo_info&.metadata&.auth_key
      service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)

      begin
        dataset = service.find_dataset_version_by_persistent_id(@persistent_id, version: version)
        if dataset.nil?
          log_error('Dataset not found.', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version })
          return ConnectorResult.new(
            message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_not_found', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) },
            success: false
          )
        end
        version = dataset.version
        files_page = service.search_dataset_files_by_persistent_id(@persistent_id, version: version, page: page, query: search_query)
        if files_page.nil?
          log_error('Dataset files not found.', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version, page: page })
          return ConnectorResult.new(
            message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_files_not_found', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version, page: page) },
            success: false
          )
        end
      rescue Dataverse::DatasetService::UnauthorizedException => e
        log_error('Dataset requires authorization', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version }, e)
        return ConnectorResult.new(
          message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_requires_authorization', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) },
          success: false
        )
      rescue => e
        log_error('Dataverse service error', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version }, e)
        return ConnectorResult.new(
          message: { alert: I18n.t('connectors.dataverse.datasets.show.dataverse_service_error', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) },
          success: false
        )
      end

      ConnectorResult.new(
        template: '/connectors/dataverse/datasets/show',
        locals: {
          dataverse_url: dataverse_url,
          dataset: dataset,
          files_page: files_page,
          repo_url: repo_url,
          persistent_id: @persistent_id
        },
        success: true
      )
    end

    def create(request_params)
      repo_url = request_params[:repo_url]
      dataverse_url = repo_url.server_url
      file_ids = request_params[:file_ids] || []
      project_id = request_params[:project_id]
      version = request_params[:version]
      page = request_params[:page] ? request_params[:page].to_i : 1
      search_query = request_params[:query].present? ? ActionView::Base.full_sanitizer.sanitize(request_params[:query]) : nil

      repo_info = RepoRegistry.repo_db.get(dataverse_url)
      api_key = repo_info&.metadata&.auth_key
      service = Dataverse::DatasetService.new(dataverse_url, api_key: api_key)

      begin
        dataset = service.find_dataset_version_by_persistent_id(@persistent_id, version: version)
        return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_not_found', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) }, success: false) unless dataset
        version = dataset.version
        files_page = service.search_dataset_files_by_persistent_id(@persistent_id, version: version, page: page, query: search_query)
        if files_page.nil?
          return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_files_not_found', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version, page: page) }, success: false)
        end
      rescue Dataverse::DatasetService::UnauthorizedException => e
        log_error('Dataset requires authorization', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version }, e)
        return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.show.dataset_requires_authorization', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) }, success: false)
      rescue => e
        log_error('Dataverse service error', { dataverse: dataverse_url, persistent_id: @persistent_id, version: version }, e)
        return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.show.dataverse_service_error', dataverse_url: dataverse_url, persistent_id: @persistent_id, version: version) }, success: false)
      end

      project = Project.find(project_id)
      project_service = Dataverse::ProjectService.new(dataverse_url)
      if project.nil?
        project = project_service.initialize_project
        unless project.save
          errors = project.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.download.error_generating_project', errors: errors) }, success: false)
        end
      end

      download_files = project_service.initialize_download_files(project, @persistent_id, dataset, files_page, file_ids)
      download_files.each do |file|
        unless file.valid?
          errors = file.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.download.invalid_file_in_selection', filename: file.filename, errors: errors) }, success: false)
        end
      end
      save_results = download_files.map(&:save)
      if save_results.include?(false)
        return ConnectorResult.new(message: { alert: I18n.t('connectors.dataverse.datasets.download.error_generating_the_download_file') }, success: false)
      end

      ConnectorResult.new(message: { notice: I18n.t('connectors.dataverse.datasets.download.files_added_to_project', project_name: project.name) }, success: true)
    end
  end
end

