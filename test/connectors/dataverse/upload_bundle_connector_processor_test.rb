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
    Dataverse::Actions::UploadBundleCreate.expects(:new).returns(action)
    action.expects(:create).with(@project, {foo: 'bar'}).returns(:ok)
    assert_equal :ok, @processor.create(@project, {foo: 'bar'})
  end

  test 'edit routes to dataset_select' do
    action = mock('action')
    Dataverse::Actions::DatasetSelect.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'dataset_select'}).returns(:res)
    assert_equal :res, @processor.edit(@bundle, {form: 'dataset_select'})
  end

  test 'update routes dataset_create form' do
    action = mock('action')
    Dataverse::Actions::DatasetCreate.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'dataset_create'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'dataset_create'})
  end
end
