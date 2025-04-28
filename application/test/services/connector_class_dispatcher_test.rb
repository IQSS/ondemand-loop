# frozen_string_literal: true
require 'test_helper'

class ConnectorClassDispatcherTest < ActiveSupport::TestCase

  test 'types should return supported connector types' do
    target = ConnectorClassDispatcher.types
    assert_instance_of ConnectorClassDispatcher::ConnectorTypes, target
    assert_equal 'dataverse', target.dataverse
  end

  test 'types should throw exception for not supported connector types' do
    target = ConnectorClassDispatcher.types
    assert_raises(ConnectorClassDispatcher::ConnectorNotSupported) do
      target.other_type
    end
  end

  test 'file_connector_status should return Dataverse::ConnectorStatus class for dataverse files' do
    collection = download_collection(type: 'dataverse', files: 1)
    result = ConnectorClassDispatcher.file_connector_status(collection.files.first)
    assert_instance_of Dataverse::ConnectorStatus, result
  end

  test 'connector_metadata should return Dataverse::ConnectorMetadata class for dataverse files' do
    collection = download_collection(type: 'dataverse', files: 1)
    result = ConnectorClassDispatcher.connector_metadata(collection.files.first)
    assert_instance_of Dataverse::ConnectorMetadata, result
  end

  test 'download_processor should return Dataverse::ConnectorDownloadProcessor class for dataverse files' do
    collection = download_collection(type: 'dataverse', files: 1)
    result = ConnectorClassDispatcher.download_processor(collection.files.first)
    assert_instance_of Dataverse::ConnectorDownloadProcessor, result
  end

end
