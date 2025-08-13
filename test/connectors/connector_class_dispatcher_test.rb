# frozen_string_literal: true
require 'test_helper'

class ConnectorClassDispatcherTest < ActiveSupport::TestCase

  test 'download_connector_status should return Dataverse::DownloadConnectorStatus class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_status(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorStatus, result
  end

  test 'upload_file_connector_status should return Dataverse::UploadConnectorStatus class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_file_connector_status(project.upload_bundles.first, project.upload_bundles.first.files.first)
    assert_instance_of Dataverse::UploadConnectorStatus, result
  end

  test 'download_connector_metadata should return Dataverse::DownloadConnectorMetadata class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_metadata(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorMetadata, result
  end

  test 'upload_bundle_connector_processor should return Dataverse::UploadBatchConnectorProcessor class for dataverse type' do
    result = ConnectorClassDispatcher.upload_bundle_connector_processor(ConnectorType::DATAVERSE)
    assert_instance_of Dataverse::UploadBundleConnectorProcessor, result
  end

  test 'upload_bundle_connector_metadata should return Dataverse::UploadBundleConnectorMetadata class for dataverse collections' do
    project = create_project
    upload_batch = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    result = ConnectorClassDispatcher.upload_bundle_connector_metadata(upload_batch)
    assert_instance_of Dataverse::UploadBundleConnectorMetadata, result
  end

  test 'download_processor should return Dataverse::DownloadConnectorProcessor class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_processor(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorProcessor, result
  end

  test 'upload_processor should return Dataverse::UploadConnectorProcessor class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_processor(project.upload_bundles.first, project.upload_bundles.first.files.first)
    assert_instance_of Dataverse::UploadConnectorProcessor, result
  end

  test 'repo_controller_resolver should return Dataverse::DisplayRepoControllerResolver class for dataverse files' do
    result = ConnectorClassDispatcher.repo_controller_resolver(ConnectorType::DATAVERSE)
    assert_instance_of Dataverse::DisplayRepoControllerResolver, result
  end

  test 'repository_settings_processor should return Dataverse::RepositorySettingsProcessor for dataverse type' do
    result = ConnectorClassDispatcher.repository_settings_processor(ConnectorType::DATAVERSE)
    assert_instance_of Dataverse::RepositorySettingsProcessor, result
  end


  test 'raises ConnectorNotSupported for unknown connector type' do
    file = OpenStruct.new(type: :unknown)
    error = assert_raises(ConnectorClassDispatcher::ConnectorNotSupported) do
      ConnectorClassDispatcher.download_connector_status(file)
    end
    assert_match /Invalid connector type/, error.message
  end

end
