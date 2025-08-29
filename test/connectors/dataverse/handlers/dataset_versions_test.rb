require 'test_helper'

class Dataverse::Handlers::DatasetVersionsTest < ActiveSupport::TestCase
  def setup
    @repo_url = Repo::RepoUrl.parse('https://dataverse.org')
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'key'))
    ::Configuration.stubs(:repo_db).returns(stub(get: repo_info))
    @explorer = Dataverse::Handlers::DatasetVersions.new('pid')
  end

  test 'params schema includes expected keys' do
    assert_includes @explorer.params_schema, :repo_url
  end

  test 'show renders versions list' do
    versions_response = OpenStruct.new(versions: [])
    service = mock('service')
    service.expects(:dataset_versions_by_persistent_id).with('pid').returns(versions_response)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)

    res = @explorer.show(repo_url: @repo_url)
    assert res.success?
    assert_equal [], res.locals[:versions]
    assert_equal @repo_url, res.locals[:repo_url]
    assert_equal 'pid', res.locals[:dataset_id]
    assert_equal '/connectors/dataverse/dataset_versions/show', res.template
  end

  test 'show handles missing versions response' do
    service = mock('service')
    service.expects(:dataset_versions_by_persistent_id).with('pid').returns(nil)
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)

    res = @explorer.show(repo_url: @repo_url)
    assert res.success?
    assert_equal [], res.locals[:versions]
  end

  test 'show propagates exceptions' do
    service = mock('service')
    service.expects(:dataset_versions_by_persistent_id).with('pid').raises(StandardError.new('boom'))
    Dataverse::DatasetService.expects(:new).with('https://dataverse.org', api_key: 'key').returns(service)

    error = assert_raises(StandardError) do
      @explorer.show(repo_url: @repo_url)
    end
    assert_equal 'boom', error.message
  end
end
