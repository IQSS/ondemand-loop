require 'test_helper'

class Zenodo::Handlers::DepositionsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(@repo_db)
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'), metadata: { auth_key: 'KEY' })
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show deposition page through explore controller' do
    deposition_json = {
      id: '10',
      submitted: false,
      metadata: {
        title: 'Deposition',
        description: 'Desc',
        publication_date: '2023-01-01'
      },
      files: [
        {
          id: 'f1',
          filename: 'file1.txt',
          filesize: 1,
          links: { self: 'https://zenodo.org/api/files/abc/file1.txt' }
        }
      ]
    }.to_json
    deposition = Zenodo::DepositionResponse.new(deposition_json)
    service = mock('deposition_service')
    service.expects(:find_deposition).with('10').returns(deposition)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'depositions',
      object_id: '10'
    )

    assert_response :success
  end
end
