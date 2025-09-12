module Zenodo::Handlers
  class Records
    include LoggingCommon

    def initialize(object_id = nil)
      @record_id = object_id
    end

    def params_schema
      [
        :repo_url,
        :project_id,
        { file_ids: [] }
      ]
    end

    def show(request_params)
      repo_url = request_params[:repo_url]
      service = Zenodo::RecordService.new(zenodo_url: repo_url.server_url)
      record = service.find_record(@record_id)
      if record.nil?
        log_error('Record not found', { repo_url: repo_url.to_s, record_id: @record_id })
        return ConnectorResult.new(
          message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) },
          success: false
        )
      end

      external_url = Zenodo::Concerns::ZenodoUrlBuilder.build_record_url(repo_url.server_url, @record_id)

      ::Configuration.repo_history.add_repo(
        external_url,
        ConnectorType::ZENODO,
        title: record.title,
        note: record.version
      )

      log_info('Records.show completed', { repo_url: repo_url.to_s, record_id: @record_id })
      ConnectorResult.new(
        template: '/connectors/zenodo/records/show',
        locals: {
          dataset: record,
          dataset_id: @record_id,
          repo_url: repo_url,
          dataset_title: record.title,
          external_zenodo_url: external_url
        },
        resource: record,
        success: true
      )
    end

    def create(request_params)
      repo_url = request_params[:repo_url]
      file_ids = request_params[:file_ids] || []
      project_id = request_params[:project_id]

      record_service = Zenodo::RecordService.new(zenodo_url: repo_url.server_url)
      record = record_service.find_record(@record_id)
      if record.nil?
        log_error('Unable to find Record', {project_id: project_id, record_id: @record_id, repo_url: repo_url.to_s})
        return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_record_not_found', record_id: @record_id) }, success: false)
      end

      project = Project.find(project_id)
      project_service = Zenodo::ProjectService.new(zenodo_url: repo_url.server_url)
      if project.nil?
        project = project_service.initialize_project
        unless project.save
          errors = project.errors.full_messages.join(', ')
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_project_error', errors: errors) }, success: false)
        end
        Current.settings.update_user_settings({ active_project: project.id.to_s })
      end

      download_files = project_service.create_files_from_record(project, record, file_ids)
      download_files.each do |file|
        unless file.valid?
          errors = file.errors.full_messages.join(', ')
          log_error('Unable to create DownloadFiles - Validation errors', {project_id: project.id.to_s, files: download_files.size, file: file.filename, errors: errors})
          return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_validation_file_error', filename: file.filename, errors: errors) }, success: false)
        end
      end
      save_results = download_files.map(&:save)
      if save_results.include?(false)
        log_error('Unable to create DownloadFiles - Save failed', {project_id: project.id.to_s, files: download_files.size})
        return ConnectorResult.new(message: { alert: I18n.t('zenodo.records.message_save_file_error', project_name: project.name) }, success: false)
      end

      log_info('Zenodo files added', {project_id: project.id.to_s, files: download_files.size})
      ConnectorResult.new(message: { notice: I18n.t('zenodo.records.message_success', files: save_results.size, project_name: project.name) }, success: true)
    end
  end
end

