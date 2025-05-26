# frozen_string_literal: true
require 'test_helper'

class RepoResolverControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect back with error if repo_url is blank' do
    post repo_resolver_url, params: { repo_url: '' }

    assert_redirected_to root_path
    assert_equal I18n.t('repo_resolver.resolve.blank_url_error'), flash[:alert]
  end

  test 'should redirect back with error if URL is unknown' do
    mock_service = mock
    mock_service.stubs(:resolve).returns(OpenStruct.new(unknown?: true, object_url: nil, type: nil))
    Repo::RepoResolverService.stubs(:new).returns(mock_service)

    post repo_resolver_url, params: { repo_url: 'https://unknown.repo.org' }

    assert_redirected_to root_path
    assert_equal I18n.t('repo_resolver.resolve.url_not_supported', url: 'https://unknown.repo.org'), flash[:alert]
  end

  test 'should redirect to resolved controller URL with optional message' do
    resolution = OpenStruct.new(
      unknown?: false,
      object_url: 'https://demo.repo.org/some/path',
      type: ConnectorType::DATAVERSE
    )

    mock_service = mock
    mock_service.stubs(:resolve).returns(resolution)
    Repo::RepoResolverService.stubs(:new).returns(mock_service)

    controller_result = OpenStruct.new(redirect_url: '/projects/123', message: { notice: 'Resolved!' })
    mock_controller = mock
    mock_controller.stubs(:get_controller_url).returns(controller_result)
    ConnectorClassDispatcher.stubs(:repo_controller_resolver).returns(mock_controller)

    post repo_resolver_url, params: { repo_url: 'https://demo.repo.org/some/path' }

    assert_redirected_to '/projects/123'
    assert_equal 'Resolved!', flash[:notice]
  end
end
