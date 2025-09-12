require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  def stub_handler(action, result: nil, exception: nil)
    handler = mock('ExploreHandler')
    handler.stubs(:params_schema).returns([])
    expectation = handler.expects(action).with(kind_of(Hash))
    expectation.returns(result) if result
    expectation.raises(exception) if exception
    ConnectorHandlerDispatcher.stubs(:handler).returns(handler)
  end

  def stub_repo_resolver(type:, object_url: 'https://example.org/')
    mock_service = mock('RepoResolverService')
    mock_service.stubs(:resolve).returns(Repo::RepoResolverResponse.new(object_url, type))
    ::Configuration.stubs(:repo_resolver_service).returns(mock_service)
  end

  test 'redirects when repo url is invalid' do
    get '/explore/zenodo/%20/records/1'

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_invalid_repo_url', repo_url: ''), flash[:alert]
  end

  test 'redirects when connector type is invalid' do
    get '/explore/bogus/example.org/records/1'

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_invalid_connector_type', connector_type: 'bogus'), flash[:alert]
  end

  test 'show action renders template when handler succeeds' do
    stub_handler(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_response :success
  end

  test 'show action renders partial when handler succeeds via ajax request' do
    stub_handler(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    ), xhr: true

    assert_response :success
  end

  test 'show action redirects to provided redirect_url when handler specifies' do
    stub_handler(:show, result: ConnectorResult.new(redirect_url: '/next', message: { notice: 'ok' }, success: true))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to '/next'
    assert_equal 'ok', flash[:notice]
  end

  test 'show action redirects back when handler requests redirect_back' do
    stub_handler(:show, result: ConnectorResult.new(redirect_back: true, message: { notice: 'ok' }, success: true))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    ), headers: { 'HTTP_REFERER' => '/previous' }

    assert_redirected_to '/previous'
    assert_equal 'ok', flash[:notice]
  end

  test 'show action redirects with message when handler fails' do
    stub_handler(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'error', flash[:alert]
  end

  test 'show action renders flash messages when handler fails via ajax request' do
    stub_handler(:show, result: ConnectorResult.new(message: { alert: 'error' }, success: false))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    ), xhr: true

    assert_response :internal_server_error
    assert_includes @response.body, 'error'
  end

  test 'show action redirects with error message when handler raises' do
    stub_handler(:show, exception: StandardError.new('boom'))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_processor_error', connector_type: 'zenodo', object_type: 'records', object_id: '1'), flash[:alert]
  end

  test 'create action redirects with message from handler' do
    stub_handler(:create, result: ConnectorResult.new(message: { notice: 'ok' }, success: true))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'ok', flash[:notice]
  end

  test 'create action redirects with error message when handler raises' do
    stub_handler(:create, exception: StandardError.new('boom'))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('explore.create.message_processor_error', connector_type: 'zenodo', object_type: 'records', object_id: '1'), flash[:alert]
  end

  test 'show action redirects when repo url type does not match the explore type' do
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://dataverse.org/')
    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'dataverse.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_repo_mismatch', repo_url: 'https://dataverse.org', repo_type: 'dataverse', explore_type: 'zenodo'), flash[:alert]
  end

  test 'create action redirects when repo url type does not match the explore type' do
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://dataverse.org/')
    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'dataverse.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_repo_mismatch', repo_url: 'https://dataverse.org', repo_type: 'dataverse', explore_type: 'zenodo'), flash[:alert]
  end

  test 'show action handles dataverse connector type' do
    stub_handler(:show, result: ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://dataverse.harvard.edu/')

    get explore_url(
      connector_type: 'dataverse',
      server_domain: 'dataverse.harvard.edu',
      object_type: 'dataset',
      object_id: 'doi:10.7910/DVN/123456',
    )

    assert_response :success
  end

  test 'create action handles dataverse connector type' do
    stub_handler(:create, result: ConnectorResult.new(message: { notice: 'Dataset downloaded' }, success: true))
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://dataverse.harvard.edu/')

    post explore_url(
      connector_type: 'dataverse',
      server_domain: 'dataverse.harvard.edu',
      object_type: 'dataset',
      object_id: 'doi:10.7910/DVN/123456',
    )

    assert_redirected_to root_path
    assert_equal 'Dataset downloaded', flash[:notice]
  end

  test 'show action passes all permitted params to handler' do
    handler = mock('ExploreHandler')
    handler.stubs(:params_schema).returns([:version, :file_id, :custom_param])
    handler.expects(:show).with({
      'version' => 'latest',
      'file_id' => '123',
      'custom_param' => 'test_value',
      'repo_url' => instance_of(Repo::RepoUrl)
    }).returns(ConnectorResult.new(template: '/sitemap/index', locals: {}, success: true))
    ConnectorHandlerDispatcher.stubs(:handler).returns(handler)
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
      version: 'latest',
      file_id: '123',
      custom_param: 'test_value',
      ignored_param: 'should_not_pass'
    )

    assert_response :success
  end

  test 'create action with failed handler result' do
    stub_handler(:create, result: ConnectorResult.new(message: { alert: 'Upload failed' }, success: false))
    stub_repo_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'example.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal 'Upload failed', flash[:alert]
  end
end

