require 'test_helper'

class Zenodo::Handlers::LandingIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(@repo_db)
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'))
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show landing page through explore controller' do
    results = Zenodo::SearchResponse.new('{}', 1, 10)
    service = mock('search_service')
    service.expects(:search).with('query', page: 1).returns(results)
    Zenodo::SearchService.expects(:new).with(zenodo_url: 'https://zenodo.org').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'landing',
      object_id: 'landing',
      query: 'query'
    )

    assert_response :success
  end
end
