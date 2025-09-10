require 'test_helper'

class Zenodo::Handlers::RecordsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(@repo_db)
    @repo_db.set('https://zenodo.org', type: ConnectorType.get('zenodo'))
    Project.stubs(:all).returns([])
    FileUtils.mkdir_p(Rails.root.join('app/assets/builds'))
    FileUtils.touch(Rails.root.join('app/assets/builds/application.css'))
  end

  test 'show record page through explore controller' do
    record_json = {
      id: '123',
      conceptrecid: '456',
      metadata: {
        title: 'Record',
        description: 'Desc',
        publication_date: '2023-01-01'
      },
      files: [
        {
          id: 'f1',
          key: 'file1.txt',
          size: 1,
          checksum: 'md5:1',
          links: { self: 'https://zenodo.org/api/files/abc/file1.txt' }
        }
      ]
    }.to_json
    record = Zenodo::RecordResponse.new(record_json)
    service = mock('record_service')
    service.expects(:find_record).with('123').returns(record)
    Zenodo::RecordService.expects(:new).with(zenodo_url: 'https://zenodo.org').returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'records',
      object_id: '123'
    )

    assert_response :success
  end
end
