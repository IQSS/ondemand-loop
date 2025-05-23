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
    result = ConnectorClassDispatcher.upload_file_connector_status(project.upload_collections.first.files.first)
    assert_instance_of Dataverse::UploadConnectorStatus, result
  end

  test 'download_connector_metadata should return Dataverse::DownloadConnectorMetadata class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_metadata(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorMetadata, result
  end

  test 'upload_connector_metadata should return Dataverse::UploadConnectorMetadata class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_connector_metadata(project.upload_collections.first.files.first)
    assert_instance_of Dataverse::UploadConnectorMetadata, result
  end

  test 'upload_collection_connector_processor should return Dataverse::UploadCollectionConnectorProcessor class for dataverse type' do
    result = ConnectorClassDispatcher.upload_collection_connector_processor(ConnectorType::DATAVERSE)
    assert_instance_of Dataverse::UploadCollectionConnectorProcessor, result
  end

  test 'upload_collection_connector_metadata should return Dataverse::UploadCollectionConnectorMetadata class for dataverse collections' do
    project = create_project
    upload_collection = create_upload_collection(project, type: ConnectorType::DATAVERSE)
    result = ConnectorClassDispatcher.upload_collection_connector_metadata(upload_collection)
    assert_instance_of Dataverse::UploadCollectionConnectorMetadata, result
  end

  test 'download_processor should return Dataverse::DownloadConnectorProcessor class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_processor(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorProcessor, result
  end

  test 'upload_processor should return Dataverse::UploadConnectorProcessor class for dataverse files' do
    project = upload_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.upload_processor(project.upload_collections.first.files.first)
    assert_instance_of Dataverse::UploadConnectorProcessor, result
  end

  test 'raises ConnectorNotSupported for unknown connector type' do
    file = OpenStruct.new(type: :unknown)
    error = assert_raises(ConnectorClassDispatcher::ConnectorNotSupported) do
      ConnectorClassDispatcher.download_connector_status(file)
    end
    assert_match /Invalid connector type/, error.message
  end

end
