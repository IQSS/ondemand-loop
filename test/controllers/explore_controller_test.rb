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

  test 'show action redirects when repo url not in repo db' do
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://missing.org/')
    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'missing.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_invalid_repo_url', repo_url: 'https://missing.org/'), flash[:alert]
  end

  test 'create action redirects when repo url not in repo db' do
    stub_repo_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://missing.org/')
    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'missing.org',
      object_type: 'records',
      object_id: '1',
    )

    assert_redirected_to root_path
    assert_equal I18n.t('connector_resolver.message_invalid_repo_url', repo_url: 'https://missing.org/'), flash[:alert]
  end
end

