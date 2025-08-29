module Zenodo::Handlers
  class UploadBundleCreate
    include LoggingCommon

    include DateTimeCommon

    def initialize(object_id = nil)
      @object_id = object_id
    end

    def params_schema
      [
        :object_url
      ]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Zenodo::ZenodoUrl.parse(remote_repo_url)
      log_info('Creating upload bundle', { project_id: project.id, remote_repo_url: remote_repo_url })
      title = concept_id = bucket_url = draft = version = nil

      if url_data.record?
        records_service = Zenodo::RecordService.new(url_data.zenodo_url)
        record = records_service.find_record(url_data.record_id)
        return error(I18n.t('connectors.zenodo.handlers.upload_bundle_create.message_record_not_found', url: remote_repo_url)) unless record

        title = record.title
        concept_id = record.concept_id
          version = record.version
      elsif url_data.deposition?
        repo_info = ::Configuration.repo_db.get(url_data.zenodo_url)
        if repo_info.metadata.auth_key.present?
          deposition_service = Zenodo::DepositionService.new(url_data.zenodo_url, api_key: repo_info.metadata.auth_key)
          deposition = deposition_service.find_deposition(url_data.deposition_id)
          return error(I18n.t('connectors.zenodo.handlers.upload_bundle_create.message_deposition_not_found', url: remote_repo_url)) unless deposition

          title = deposition.title
          bucket_url = deposition.bucket_url
          draft = deposition.draft?
          version = deposition.version
        end

      end

      ::Configuration.repo_history.add_repo(
        remote_repo_url,
        ConnectorType::ZENODO,
        title: title,
        note: version
      )

      file_utils = Common::FileUtils.new
      upload_bundle = UploadBundle.new.tap do |bundle|
        bundle.id = file_utils.normalize_name(File.join(url_data.domain, UploadBundle.generate_code))
        bundle.name = url_data.domain
        bundle.project_id = project.id
        bundle.remote_repo_url = remote_repo_url
        bundle.type = ConnectorType::ZENODO
        bundle.creation_date = now
        bundle.metadata = {
          zenodo_url: url_data.zenodo_url,
          title: title,
          record_id: url_data.record_id,
          concept_id: concept_id,
          deposition_id: url_data.deposition_id,
          bucket_url: bucket_url,
          draft: draft
        }
      end
      upload_bundle.save
      log_info('Upload bundle created', { bundle_id: upload_bundle.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.handlers.upload_bundle_create.message_success', name: upload_bundle.name) },
        success: true
      )
    rescue Zenodo::ApiService::UnauthorizedException => e
      log_error('Auth error creating upload bundle', { project: project.id, remote_repo_url: remote_repo_url }, e)
      return error(I18n.t('connectors.zenodo.handlers.upload_bundle_create.message_auth_error'))
    end

    private

    def error(message)
      ConnectorResult.new(
        message: { alert: message },
        success: false
      )
    end
  end
end
