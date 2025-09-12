# frozen_string_literal: true

module Zenodo::Handlers
  # Handler to create an UploadBundle from a Zenodo record URL
  class UploadBundleCreateFromRecord
    include LoggingCommon
    include DateTimeCommon

    # Needed to implement expected interface in ConnectorHandlerDispatcher
    def initialize(object = nil); end

    def params_schema
      [:object_url]
    end

    def create(project, request_params)
      remote_repo_url = request_params[:object_url]
      url_data = Zenodo::ZenodoUrl.parse(remote_repo_url)
      log_info('Creating upload bundle from record', { project_id: project.id, remote_repo_url: remote_repo_url })

      records_service = Zenodo::RecordService.new(zenodo_url: url_data.zenodo_url)
      record = records_service.find_record(url_data.record_id)
      return error(I18n.t('connectors.zenodo.handlers.upload_bundle_create_from_record.message_record_not_found', url: remote_repo_url)) unless record

      title = record.title
      concept_id = record.concept_id
      version = record.version

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
          bucket_url: nil,
          draft: nil
        }
      end
      upload_bundle.save
      log_info('Upload bundle created from record', { bundle_id: upload_bundle.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.handlers.upload_bundle_create_from_record.message_success', name: upload_bundle.name) },
        success: true
      )
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

