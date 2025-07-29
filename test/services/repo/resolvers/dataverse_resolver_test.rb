require 'test_helper'

class Repo::Resolvers::DataverseResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @repo_db_temp = Tempfile.new('repo_db')
    @repo_db = Repo::RepoDb.new(db_path: @repo_db_temp.path)
  end

  def teardown
    @repo_db_temp.unlink
  end

  test 'resolve returns cached entry without api call' do
    @repo_db.set('https://dv.org', type: ConnectorType::DATAVERSE, metadata: { api_version: '5.0' })
    http_client = mock('client')
    http_client.expects(:get).never

    resolver = Repo::Resolvers::DataverseResolver.new

    context = Repo::RepoResolverContext.new('https://dv.org/dataverse', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://dv.org/dataverse'
    resolver.resolve(context)

    assert_equal ConnectorType::DATAVERSE, context.type
  end

  test 'resolve falls back to API when domain unknown' do
    body = { data: { version: '1.0' } }.to_json
    response = stub(success?: true, json: JSON.parse(body))
    http_client = mock('client')
    http_client.expects(:get).returns(response)

    resolver = Repo::Resolvers::DataverseResolver.new
    context = Repo::RepoResolverContext.new('https://unknown.org/dataverse', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://unknown.org/dataverse'

    resolver.resolve(context)

    assert_equal ConnectorType::DATAVERSE, context.type
    entry = @repo_db.get('https://unknown.org')
    assert entry
    assert_equal '1.0', entry.metadata.api_version
  end

  test 'resolve handles api failures gracefully' do
    http_client = mock('client')
    http_client.expects(:get).raises(StandardError.new('boom'))
    resolver = Repo::Resolvers::DataverseResolver.new

    context = Repo::RepoResolverContext.new('https://fail.org/dataverse', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://fail.org/dataverse'

    resolver.resolve(context)

    assert_nil context.type
  end
end
