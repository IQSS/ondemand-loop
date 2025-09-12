require 'test_helper'

class Zenodo::UploadBundleConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper
  include LoggingCommonMock

  def setup
    @processor = Zenodo::UploadBundleConnectorProcessor.new
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @processor.extend(LoggingCommonMock)
  end

  test 'params schema' do
    assert_includes @processor.params_schema, :remote_repo_url
  end

  test 'create delegates to record handler' do
    url_data = OpenStruct.new(record?: true, deposition?: false)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)
    action = mock('action')
    Zenodo::Handlers::UploadBundleCreateFromRecord.expects(:new).returns(action)
    action.expects(:create).with(@project, {foo: 'bar'}).returns(:result)
    assert_equal :result, @processor.create(@project, {foo: 'bar'})
  end

  test 'create delegates to deposition handler' do
    url_data = OpenStruct.new(record?: false, deposition?: true)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)
    action = mock('action')
    Zenodo::Handlers::UploadBundleCreateFromDeposition.expects(:new).returns(action)
    action.expects(:create).with(@project, {foo: 'bar'}).returns(:result)
    assert_equal :result, @processor.create(@project, {foo: 'bar'})
  end

  test 'create delegates to generic handler' do
    url_data = OpenStruct.new(record?: false, deposition?: false)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)
    action = mock('action')
    Zenodo::Handlers::UploadBundleCreateFromServer.expects(:new).returns(action)
    action.expects(:create).with(@project, {foo: 'bar'}).returns(:result)
    assert_equal :result, @processor.create(@project, {foo: 'bar'})
  end

  test 'edit returns connector result by default' do
    result = @processor.edit(@bundle, {})
    assert_equal '/connectors/zenodo/connector_edit_form', result.template
    assert_equal({upload_bundle: @bundle}, result.locals)
  end

  test 'edit uses dataset_form_tabs form' do
    action = mock('action')
    Zenodo::Handlers::DatasetFormTabs.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {form: 'dataset_form_tabs'}).returns(:ok)
    assert_equal :ok, @processor.edit(@bundle, {form: 'dataset_form_tabs'})
  end

  test 'update uses deposition_fetch form' do
    action = mock('action')
    Zenodo::Handlers::DepositionFetch.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'deposition_fetch'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'deposition_fetch'})
  end

  test 'update uses deposition_create form' do
    action = mock('action')
    Zenodo::Handlers::DepositionCreate.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'deposition_create'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'deposition_create'})
  end

  test 'update uses dataset_select form' do
    action = mock('action')
    Zenodo::Handlers::DatasetSelect.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {form: 'dataset_select'}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {form: 'dataset_select'})
  end

  test 'update default routes to connector edit' do
    action = mock('action')
    Zenodo::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {}).returns(:ok)
    assert_equal :ok, @processor.update(@bundle, {})
  end

  test 'initialize accepts optional parameter' do
    processor_with_param = Zenodo::UploadBundleConnectorProcessor.new('test_param')
    assert_not_nil processor_with_param
  end

  test 'params schema includes all expected parameters' do
    expected_params = %i[remote_repo_url form api_key key_scope title upload_type description creators deposition_id]
    expected_params.each do |param|
      assert_includes @processor.params_schema, param, "Missing parameter: #{param}"
    end
  end

  test 'create handles exception and returns error result' do
    url_data = OpenStruct.new(record?: false, deposition?: false)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    @processor.expects(:log_error).with('UploadBundle creation error', { remote_repo_url: 'https://example.com' }, instance_of(RuntimeError))

    Zenodo::Handlers::UploadBundleCreateFromServer.any_instance.stubs(:create).raises(RuntimeError.new('Test error'))

    result = @processor.create(@project, { object_url: 'https://example.com' })
    assert_equal false, result.success?
  end

  test 'create uses object_url parameter correctly' do
    url_data = OpenStruct.new(record?: false, deposition?: false)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)
    action = mock('action')
    Zenodo::Handlers::UploadBundleCreateFromServer.expects(:new).returns(action)
    action.expects(:create).with(@project, { object_url: 'https://test.com', other_param: 'value' }).returns(:result)
    assert_equal :result, @processor.create(@project, { object_url: 'https://test.com', other_param: 'value' })
  end

  test 'edit handles deposition_create form case' do
    action = mock('action')
    Zenodo::Handlers::DepositionCreate.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, { form: 'deposition_create' }).returns(:deposition_result)
    assert_equal :deposition_result, @processor.edit(@bundle, { form: 'deposition_create' })
  end

  test 'edit handles exception and returns error result' do
    @processor.expects(:log_error).with('UploadBundle edit error', { bundle_id: @bundle.id, form: 'test_form' }, instance_of(RuntimeError))
    
    Zenodo::Handlers::ConnectorEdit.any_instance.stubs(:edit).raises(RuntimeError.new('Test error'))
    
    result = @processor.edit(@bundle, { form: 'test_form' })
    assert_equal false, result.success?
  end

  test 'update handles dataset_form_tabs form' do
    action = mock('action')
    Zenodo::Handlers::DatasetFormTabs.expects(:new).returns(action)
    action.expects(:update).with(@bundle, { form: 'dataset_form_tabs' }).returns(:tabs_result)
    assert_equal :tabs_result, @processor.update(@bundle, { form: 'dataset_form_tabs' })
  end

  test 'update handles exception and returns error result' do
    @processor.expects(:log_error).with('UploadBundle update error', { bundle_id: @bundle.id, form: 'invalid_form' }, instance_of(RuntimeError))
    
    Zenodo::Handlers::ConnectorEdit.any_instance.stubs(:update).raises(RuntimeError.new('Test error'))
    
    result = @processor.update(@bundle, { form: 'invalid_form' })
    assert_equal false, result.success?
  end

  test 'edit returns connector edit result for empty form parameter' do
    action = mock('action')
    Zenodo::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, { form: '' }).returns(:connector_result)
    assert_equal :connector_result, @processor.edit(@bundle, { form: '' })
  end

  test 'edit returns connector edit result for nil form parameter' do
    action = mock('action')
    Zenodo::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:edit).with(@bundle, {}).returns(:connector_result)
    assert_equal :connector_result, @processor.edit(@bundle, {})
  end

  test 'update returns connector edit result for empty form parameter' do
    action = mock('action')
    Zenodo::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:update).with(@bundle, { form: '' }).returns(:connector_result)
    assert_equal :connector_result, @processor.update(@bundle, { form: '' })
  end

  test 'update returns connector edit result for nil form parameter' do
    action = mock('action')
    Zenodo::Handlers::ConnectorEdit.expects(:new).returns(action)
    action.expects(:update).with(@bundle, {}).returns(:connector_result)
    assert_equal :connector_result, @processor.update(@bundle, {})
  end

  test 'error method creates proper connector result' do
    result = @processor.send(:error, 'Test error message')
    assert_equal false, result.success?
    assert_equal 'Test error message', result.message[:alert]
  end
end
