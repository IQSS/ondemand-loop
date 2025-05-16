# frozen_string_literal: true
require 'test_helper'

class ConnectorClassDispatcherTest < ActiveSupport::TestCase

  test 'file_connector_status should return Dataverse::DownloadConnectorStatus class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_status(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorStatus, result
  end

  test 'connector_metadata should return Dataverse::DownloadConnectorMetadata class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_connector_metadata(project.download_files.first)
    assert_instance_of Dataverse::DownloadConnectorMetadata, result
  end

  test 'download_processor should return Dataverse::ConnectorDownloadProcessor class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_processor(project.download_files.first)
    assert_instance_of Dataverse::ConnectorDownloadProcessor, result
  end

end
