require 'test_helper'

class ConnectorResolverTest < ActionController::TestCase
  class DummyController < ActionController::Base
    include LoggingCommon
    include ConnectorResolver

    before_action :parse_connector_type
    before_action :build_repo_url
    before_action :validate_repo_url

    def show
      render plain: 'ok'
    end
  end

  tests DummyController

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'show' => 'connector_resolver_test/dummy#show'
      root to: 'connector_resolver_test/dummy#show'
    end
    @request.env['action_dispatch.routes'] = @routes
  end

  def stub_resolver(type:, object_url: 'https://example.org/')
    mock_service = mock('RepoResolverService')
    mock_service.stubs(:resolve).returns(Repo::RepoResolverResponse.new(object_url, type))
    Repo::RepoResolverService.stubs(:new).returns(mock_service)
  end

  test 'validate_repo_url redirects when repo type mismatches' do
    stub_resolver(type: ConnectorType.get('dataverse'), object_url: 'https://example.org/')
    get :show, params: { connector_type: 'zenodo', server_domain: 'example.org' }
    assert_redirected_to '/'
  end

  test 'validate_repo_url allows matching repo type' do
    stub_resolver(type: ConnectorType.get('zenodo'), object_url: 'https://example.org/')
    get :show, params: { connector_type: 'zenodo', server_domain: 'example.org' }
    assert_response :success
  end
end
