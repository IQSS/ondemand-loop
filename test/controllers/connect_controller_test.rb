require 'test_helper'

class ConnectControllerTest < ActionDispatch::IntegrationTest
  def stub_handler(action, result: nil, exception: nil, object_type: 'landing')
    handler = mock('ConnectHandler')
    handler.stubs(:params_schema).returns([])
    expectation = handler.expects(action).with(kind_of(Hash))
    expectation.returns(result) if result
    expectation.raises(exception) if exception
    ConnectorHandlerDispatcher.stubs(:handler).with(ConnectorType::ZENODO, object_type).returns(handler)
  end

  test 'show action renders template when handler succeeds' do
    stub_handler(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))

    get connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_response :success
  end

  test 'show action redirects with message when handler fails' do
    stub_handler(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    get connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'show action redirects with error message when handler raises' do
    stub_handler(:show, exception: StandardError.new('boom'))

    get connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_redirected_to root_path
    assert_equal I18n.t('connect.show.message_processor_error', connector_type: 'zenodo', action: 'landing'), flash[:alert]
  end

  test 'handle action redirects with message when handler succeeds' do
    stub_handler(:handle, result: ConnectorResult.new(redirect_url: root_path, message: { notice: 'ok' }, success: true))

    post connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_redirected_to root_path
    assert_equal 'ok', flash[:notice]
  end

  test 'handle action redirects with message when handler fails' do
    stub_handler(:handle, result: ConnectorResult.new(message: { alert: 'error' }, success: false))

    post connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'handle action redirects with error message when handler raises' do
    stub_handler(:handle, exception: StandardError.new('boom'))

    post connect_repo_url(connector_type: 'zenodo', object_type: 'landing')
    assert_redirected_to root_path
    assert_equal I18n.t('connect.handle.message_processor_error', connector_type: 'zenodo', action: 'landing'), flash[:alert]
  end
end
