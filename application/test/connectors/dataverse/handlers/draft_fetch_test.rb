require 'test_helper'

class Dataverse::Handlers::DraftFetchTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Dataverse::Handlers::DraftFetch.new
    
    # Create real upload bundle
    @upload_bundle = UploadBundle.new
    @upload_bundle.id = 'test-bundle-123'
    @upload_bundle.project_id = @project.id
    @upload_bundle.remote_repo_url = 'https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/TEST123&version=DRAFT'
    @upload_bundle.type = ConnectorType::DATAVERSE
    @upload_bundle.metadata = {
      dataverse_url: 'https://dataverse.harvard.edu',
      dataverse_title: 'Harvard Dataverse',
      collection_title: nil,
      dataset_title: nil,
      collection_id: nil,
      dataset_id: 'doi:10.7910/DVN/TEST123',
      auth_key: 'test-api-key-123'
    }
    
    ::Configuration.repo_history.stubs(:add_repo)
  end

  test 'params schema is empty' do
    assert_empty @action.params_schema
  end

  test 'update successfully fetches draft dataset with parent collection' do
    # Mock dataset with parent collection
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [
      {name: 'Harvard Dataverse', identifier: 'harvard'},
      {name: 'Social Sciences', identifier: 'socialsciences'}
    ])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('Draft COVID-19 Survey Data')
    dataset.stubs(:version).returns(':draft')
    
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.7910/DVN/TEST123', version: ':draft').returns(dataset)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'test-api-key-123').returns(dataset_service)
    
    # Expect metadata update
    updated_metadata = @upload_bundle.metadata.dup
    updated_metadata[:dataset_title] = 'Draft COVID-19 Survey Data'
    updated_metadata[:collection_title] = 'Social Sciences'
    updated_metadata[:collection_id] = 'socialsciences'
    @upload_bundle.expects(:update).with({ metadata: updated_metadata })
    
    result = @action.update(@upload_bundle, {})
    
    assert result.success?
    assert_match(/Draft dataset data fetched successfully/, result.message[:notice])
    assert_match(/Draft COVID-19 Survey Data/, result.message[:notice])
  end

  test 'update successfully fetches draft dataset without parent collection' do
    # Mock dataset without parents
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('Orphan Draft Dataset')
    dataset.stubs(:version).returns(':draft')
    
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.7910/DVN/TEST123', version: ':draft').returns(dataset)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'test-api-key-123').returns(dataset_service)
    
    # Expect metadata update (no collection info updated)
    updated_metadata = @upload_bundle.metadata.dup
    updated_metadata[:dataset_title] = 'Orphan Draft Dataset'
    @upload_bundle.expects(:update).with({ metadata: updated_metadata })
    
    result = @action.update(@upload_bundle, {})
    
    assert result.success?
    assert_match(/Draft dataset data fetched successfully/, result.message[:notice])
    assert_match(/Orphan Draft Dataset/, result.message[:notice])
  end

  test 'update handles missing API key error' do
    # Mock connector metadata without API key
    @upload_bundle.metadata[:auth_key] = nil

    result = @action.update(@upload_bundle, {})
    
    assert_not result.success?
    assert_equal I18n.t('connectors.dataverse.handlers.draft_fetch.message_no_api_key'), result.message[:alert]
  end

  test 'update handles missing dataset ID error' do
    # Mock connector metadata without dataset ID
    @upload_bundle.metadata[:dataset_id] = nil
    
    result = @action.update(@upload_bundle, {})
    
    assert_not result.success?
    assert_equal I18n.t('connectors.dataverse.handlers.draft_fetch.message_no_dataset_id'), result.message[:alert]
  end

  test 'update handles dataset not found error' do
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).with('doi:10.7910/DVN/TEST123', version: ':draft').returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'test-api-key-123').returns(dataset_service)
    
    result = @action.update(@upload_bundle, {})
    
    assert_not result.success?
    assert_equal I18n.t('connectors.dataverse.handlers.draft_fetch.message_dataset_not_found'), result.message[:alert]
  end

  test 'update handles unauthorized access error' do
    dataset_service = mock('dataset_service')
    dataset_service.expects(:find_dataset_version_by_persistent_id).raises(Dataverse::DatasetService::UnauthorizedException.new('Unauthorized'))
    Dataverse::DatasetService.expects(:new).with('https://dataverse.harvard.edu', api_key: 'test-api-key-123').returns(dataset_service)
    
    result = @action.update(@upload_bundle, {})
    
    assert_not result.success?
    assert_equal I18n.t('connectors.dataverse.handlers.draft_fetch.message_unauthorized'), result.message[:alert]
  end

  test 'update adds repo history with correct parameters' do
    dataset = mock('dataset')
    dataset.stubs(:data).returns(OpenStruct.new(parents: []))
    dataset.stubs(:metadata_field).with('title').returns('History Test Dataset')
    dataset.stubs(:version).returns(':draft')
    
    Dataverse::DatasetService.stubs(:new).returns(stub(find_dataset_version_by_persistent_id: dataset))
    @upload_bundle.stubs(:update)
    
    ::Configuration.repo_history.expects(:add_repo).with(
      'https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/TEST123&version=DRAFT',
      ConnectorType::DATAVERSE,
      title: 'History Test Dataset',
      note: ':draft'
    )
    
    @action.update(@upload_bundle, {})
  end

  test 'update correctly updates metadata structure' do
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [
      {name: 'Root Dataverse', identifier: 'root'},
      {name: 'Research Collection', identifier: 'research'}
    ])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('Metadata Test Dataset')
    dataset.stubs(:version).returns(':draft')
    
    Dataverse::DatasetService.stubs(:new).returns(stub(find_dataset_version_by_persistent_id: dataset))
    
    # Capture the metadata update
    expected_metadata = @upload_bundle.metadata.dup
    expected_metadata[:dataset_title] = 'Metadata Test Dataset'
    expected_metadata[:collection_title] = 'Research Collection'
    expected_metadata[:collection_id] = 'research'
    
    @upload_bundle.expects(:update).with({ metadata: expected_metadata })
    
    result = @action.update(@upload_bundle, {})
    assert result.success?
  end

  test 'update handles empty parents array' do
    dataset = mock('dataset')
    dataset_data = OpenStruct.new(parents: [])
    dataset.stubs(:data).returns(dataset_data)
    dataset.stubs(:metadata_field).with('title').returns('No Parents Dataset')
    dataset.stubs(:version).returns(':draft')
    
    Dataverse::DatasetService.stubs(:new).returns(stub(find_dataset_version_by_persistent_id: dataset))
    
    # Should not update collection info when no parents
    expected_metadata = @upload_bundle.metadata.dup
    expected_metadata[:dataset_title] = 'No Parents Dataset'
    # collection_title and collection_id should remain unchanged
    
    @upload_bundle.expects(:update).with({ metadata: expected_metadata })
    
    result = @action.update(@upload_bundle, {})
    assert result.success?
  end

  test 'error helper returns proper ConnectorResult' do
    result = @action.send(:error, 'Test draft fetch error message')
    
    assert_not result.success?
    assert_equal 'Test draft fetch error message', result.message[:alert]
    assert_instance_of ConnectorResult, result
  end
end