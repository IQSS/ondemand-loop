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

  test 'create delegates to action' do
    action = mock('action')
    Dataverse::Handlers::UploadBundleCreate.expects(:new).returns(action)
    action.expects(:create).with(@project, {foo: 'bar'}).returns(:ok)
    assert_equal :ok, @processor.create(@project, {foo: 'bar'})
  end

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

  test 'update defaults to connector_edit' do
    action = mock('action')
    Dataverse::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'unknown'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'unknown'})
  end
end
