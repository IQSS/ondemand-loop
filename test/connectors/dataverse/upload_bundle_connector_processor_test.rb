require 'test_helper'

class Dataverse::UploadBundleConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @processor = Dataverse::UploadBundleConnectorProcessor.new
    @project = create_project
    @bundle = create_upload_bundle(@project)
  end

  test 'params schema includes remote_repo_url' do
    assert_includes @processor.params_schema, :remote_repo_url
  end

  # CREATE method tests
  test 'create routes to collection handler for collection URLs' do
    collection_url_data = mock('url_data')
    collection_url_data.stubs(:collection?).returns(true)
    collection_url_data.stubs(:dataset?).returns(false)
    Dataverse::DataverseUrl.expects(:parse).with('http://example.com/dataverse/collection').returns(collection_url_data)
    
    handler = mock('handler')
    Dataverse::Handlers::UploadBundleCreateFromCollection.expects(:new).returns(handler)
    handler.expects(:create).with(@project, {object_url: 'http://example.com/dataverse/collection'}).returns(:collection_result)
    
    result = @processor.create(@project, {object_url: 'http://example.com/dataverse/collection'})
    assert_equal :collection_result, result
  end

  test 'create routes to dataset handler for dataset URLs' do
    dataset_url_data = mock('url_data')
    dataset_url_data.stubs(:collection?).returns(false)
    dataset_url_data.stubs(:dataset?).returns(true)
    Dataverse::DataverseUrl.expects(:parse).with('http://example.com/dataset?id=123').returns(dataset_url_data)
    
    handler = mock('handler')
    Dataverse::Handlers::UploadBundleCreateFromDataset.expects(:new).returns(handler)
    handler.expects(:create).with(@project, {object_url: 'http://example.com/dataset?id=123'}).returns(:dataset_result)
    
    result = @processor.create(@project, {object_url: 'http://example.com/dataset?id=123'})
    assert_equal :dataset_result, result
  end

  test 'create routes to dataverse handler for root dataverse URLs' do
    dataverse_url_data = mock('url_data')
    dataverse_url_data.stubs(:collection?).returns(false)
    dataverse_url_data.stubs(:dataset?).returns(false)
    Dataverse::DataverseUrl.expects(:parse).with('http://example.com').returns(dataverse_url_data)
    
    handler = mock('handler')
    Dataverse::Handlers::UploadBundleCreateFromDataverse.expects(:new).returns(handler)
    handler.expects(:create).with(@project, {object_url: 'http://example.com'}).returns(:dataverse_result)
    
    result = @processor.create(@project, {object_url: 'http://example.com'})
    assert_equal :dataverse_result, result
  end

  test 'create handles errors gracefully' do
    Dataverse::DataverseUrl.expects(:parse).raises(StandardError.new('Parse error'))
    
    @processor.expects(:log_error).with('UploadBundle creation error', { remote_repo_url: 'http://bad-url.com' }, kind_of(StandardError))
    
    result = @processor.create(@project, {object_url: 'http://bad-url.com'})
    
    assert_not result.success?
    assert_match(/Error/, result.message[:alert])
  end

  # EDIT method tests
  test 'edit routes to dataset_select' do
    action = mock('action')
    Dataverse::Handlers::DatasetSelect.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'dataset_select'}).returns(:res)
    assert_equal :res, @processor.edit(@bundle, {form: 'dataset_select'})
  end

  test 'edit routes dataset_form_tabs' do
    action = mock('action')
    Dataverse::Handlers::DatasetFormTabs.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'dataset_form_tabs'}).returns(:ok)
    assert_equal :ok, @processor.edit(@bundle, {form: 'dataset_form_tabs'})
  end

  test 'edit routes dataset_create form' do
    action = mock('action')
    Dataverse::Handlers::DatasetCreate.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'dataset_create'}).returns(:ok)
    assert_equal :ok, @processor.edit(@bundle, {form: 'dataset_create'})
  end

  test 'edit routes collection_select form' do
    action = mock('action')
    Dataverse::Handlers::CollectionSelect.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'collection_select'}).returns(:ok)
    assert_equal :ok, @processor.edit(@bundle, {form: 'collection_select'})
  end

  test 'edit defaults to connector_edit' do
    action = mock('action')
    Dataverse::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'other'}).returns(:ok)
    assert_equal :ok, @processor.edit(@bundle, {form: 'other'})
  end

  test 'edit handles errors gracefully' do
    Dataverse::Handlers::ConnectorEdit.expects(:new).raises(StandardError.new('Handler error'))
    
    @processor.expects(:log_error).with('UploadBundle edit error', { bundle_id: @bundle.id, form: 'unknown' }, kind_of(StandardError))
    
    result = @processor.edit(@bundle, {form: 'unknown'})
    
    assert_not result.success?
    assert_match(/Error/, result.message[:alert])
  end

  test 'update routes dataset_create form' do
    action = mock('action')
    Dataverse::Handlers::DatasetCreate.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'dataset_create'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'dataset_create'})
  end

  test 'update routes dataset_form_tabs form' do
    action = mock('action')
    Dataverse::Handlers::DatasetFormTabs.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'dataset_form_tabs'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'dataset_form_tabs'})
  end

  test 'update routes dataset_select form' do
    action = mock('action')
    Dataverse::Handlers::DatasetSelect.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'dataset_select'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'dataset_select'})
  end

  test 'update routes collection_select form' do
    action = mock('action')
    Dataverse::Handlers::CollectionSelect.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'collection_select'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'collection_select'})
  end

  test 'update routes draft_fetch form' do
    action = mock('action')
    Dataverse::Handlers::DraftFetch.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'draft_fetch'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'draft_fetch'})
  end

  test 'update defaults to connector_edit' do
    action = mock('action')
    Dataverse::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'unknown'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'unknown'})
  end

  test 'update handles errors gracefully' do
    Dataverse::Handlers::ConnectorEdit.expects(:new).raises(StandardError.new('Update error'))
    
    @processor.expects(:log_error).with('UploadBundle update error', { bundle_id: @bundle.id, form: 'failing_form' }, kind_of(StandardError))
    
    result = @processor.update(@bundle, {form: 'failing_form'})
    
    assert_not result.success?
    assert_match(/Error/, result.message[:alert])
  end
end
