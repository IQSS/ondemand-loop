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

  test 'resolve uses hub registry when domain is known' do
    registry = OpenStruct.new(installations: [{ hostname: 'dv.org' }])
    resolver = Repo::Resolvers::DataverseResolver.new(dataverse_hub_registry: registry)

    context = Repo::RepoResolverContext.new('https://dv.org/dataverse', repo_db: @repo_db)
    context.object_url = 'https://dv.org/dataverse'
    resolver.resolve(context)

    assert_equal ConnectorType::DATAVERSE, context.type
    assert @repo_db.get('https://dv.org')
  end

  test 'resolve falls back to API when domain unknown' do
    body = { data: { version: '1.0' } }.to_json
    response = stub(success?: true, json: JSON.parse(body))
    http_client = mock('client')
    http_client.expects(:get).returns(response)

    registry = OpenStruct.new(installations: [])
    resolver = Repo::Resolvers::DataverseResolver.new(dataverse_hub_registry: registry)
    context = Repo::RepoResolverContext.new('https://unknown.org/dataverse', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://unknown.org/dataverse'

    resolver.resolve(context)

    assert_equal ConnectorType::DATAVERSE, context.type
    assert @repo_db.get('https://unknown.org')
  end

  test 'resolve handles api failures gracefully' do
    http_client = mock('client')
    http_client.expects(:get).raises(StandardError.new('boom'))
    registry = OpenStruct.new(installations: [])
    resolver = Repo::Resolvers::DataverseResolver.new(dataverse_hub_registry: registry)

    context = Repo::RepoResolverContext.new('https://fail.org/dataverse', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://fail.org/dataverse'

    resolver.resolve(context)

    assert_nil context.type
  end
end
