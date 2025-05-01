# frozen_string_literal: true
require 'test_helper'

class ConnectorClassDispatcherTest < ActiveSupport::TestCase

  test 'file_connector_status should return Dataverse::ConnectorStatus class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.file_connector_status(project.files.first)
    assert_instance_of Dataverse::ConnectorStatus, result
  end

  test 'connector_metadata should return Dataverse::ConnectorMetadata class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.connector_metadata(project.files.first)
    assert_instance_of Dataverse::ConnectorMetadata, result
  end

  test 'download_processor should return Dataverse::ConnectorDownloadProcessor class for dataverse files' do
    project = download_project(type: ConnectorType::DATAVERSE, files: 1)
    result = ConnectorClassDispatcher.download_processor(project.files.first)
    assert_instance_of Dataverse::ConnectorDownloadProcessor, result
  end

end
