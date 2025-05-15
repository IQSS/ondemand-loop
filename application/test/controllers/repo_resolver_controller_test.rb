require 'test_helper'

class RepoResolverControllerTest < ActionDispatch::IntegrationTest
  test 'redirects back with alert when url param is blank' do
    post repo_resolver_url, params: { url: '' }
    assert_redirected_to root_path
    assert_equal 'Please provide repo URL', flash[:alert]
  end

  test 'redirects to dataverse dataset view when resolver returns dataverse type' do
    mock_repo_info = {
      type: 'dataverse',
      doi: '10.1234/abcde',
      object_url: 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/abcde'
    }

    RepoResolversRegistry.stubs(:resolvers).returns([])
    Repo::RepoResolverService.any_instance.stubs(:resolve).returns(mock_repo_info)

    post repo_resolver_url, params: { url: 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/abcde' }

    assert_redirected_to view_dataverse_dataset_path(dv_hostname: 'demo.dataverse.org', persistent_id: '10.1234/abcde')
  end

  test 'redirects to dataverse dataset view with extra parameters when required' do
    mock_repo_info = {
      type: 'dataverse',
      doi: '10.1234/abcde',
      object_url: 'http://demo.dataverse.org:33000/dataset.xhtml?persistentId=doi:10.1234/abcde'
    }

    RepoResolversRegistry.stubs(:resolvers).returns([])
    Repo::RepoResolverService.any_instance.stubs(:resolve).returns(mock_repo_info)

    post repo_resolver_url, params: { url: 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/abcde' }

    assert_redirected_to view_dataverse_dataset_path(dv_hostname: 'demo.dataverse.org', persistent_id: '10.1234/abcde', dv_scheme: 'http', dv_port: '33000')
  end

  test 'redirects back with alert when resolver returns unknown type' do
    mock_repo_info = { type: 'Unknown' }

    RepoResolversRegistry.stubs(:resolvers).returns([])
    Repo::RepoResolverService.any_instance.stubs(:resolve).returns(mock_repo_info)

    url = 'https://unknown-repo.org/object/123'
    post repo_resolver_url, params: { url: url }

    assert_redirected_to root_path
    assert_includes flash[:alert], 'type: Unknown'
    assert_includes flash[:alert], url
  end
end
