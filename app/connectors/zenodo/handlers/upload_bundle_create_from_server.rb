# frozen_string_literal: true

module Zenodo::Handlers
  # Handler to create an UploadBundle from a Zenodo server URL
  class UploadBundleCreateFromServer
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
      log_info('Creating upload bundle from server', { project_id: project.id, remote_repo_url: remote_repo_url })

      ::Configuration.repo_history.add_repo(
        remote_repo_url,
        ConnectorType::ZENODO,
        title: nil,
        note: nil
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
          title: nil,
          record_id: url_data.record_id,
          concept_id: nil,
          deposition_id: url_data.deposition_id,
          bucket_url: nil,
          draft: nil
        }
      end
      upload_bundle.save
      log_info('Upload bundle created from server', { bundle_id: upload_bundle.id })

      ConnectorResult.new(
        resource: upload_bundle,
        message: { notice: I18n.t('connectors.zenodo.handlers.upload_bundle_create_from_server.message_success', name: upload_bundle.name) },
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
