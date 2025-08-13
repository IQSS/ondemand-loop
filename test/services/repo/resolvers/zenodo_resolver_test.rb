# frozen_string_literal: true
require 'test_helper'

class Repo::Resolvers::ZenodoResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @repo_db_temp = Tempfile.new('repo_db')
    @repo_db = Repo::RepoDb.new(db_path: @repo_db_temp.path)
  end

  def teardown
    @repo_db_temp.unlink
  end

  test 'resolve falls back to API when domain unknown and detects Zenodo' do
    body = { 'hits' => { 'total' => 1, 'hits' => [] } }.to_json
    response = stub(success?: true, json: JSON.parse(body))
    http_client = mock('client')
    http_client.expects(:get)
               .with('https://unknown.org/api/records?page=1&size=1')
               .returns(response)

    resolver = Repo::Resolvers::ZenodoResolver.new
    context = Repo::RepoResolverContext.new('https://unknown.org/records/123', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://unknown.org/records/123'

    resolver.resolve(context)

    assert_equal ConnectorType::ZENODO, context.type
    entry = @repo_db.get('https://unknown.org')
    assert entry
    assert_equal ConnectorType::ZENODO, entry.type
  end

  test 'resolve handles api failures gracefully' do
    http_client = mock('client')
    http_client.expects(:get).raises(StandardError.new('boom'))

    resolver = Repo::Resolvers::ZenodoResolver.new
    context = Repo::RepoResolverContext.new('https://fail.org/records/123', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://fail.org/records/123'

    resolver.resolve(context)

    assert_nil context.type
  end

  test 'resolve does not set type if JSON is missing hits key' do
    body = { 'not_hits' => {} }.to_json
    response = stub(success?: true, json: JSON.parse(body))
    http_client = mock('client')
    http_client.expects(:get)
               .with('https://bad.org/api/records?page=1&size=1')
               .returns(response)

    resolver = Repo::Resolvers::ZenodoResolver.new
    context = Repo::RepoResolverContext.new('https://bad.org/records/123', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://bad.org/records/123'

    resolver.resolve(context)

    assert_nil context.type
    assert_nil @repo_db.get('https://bad.org')
  end

  test 'resolve does not set type if hits is not a hash' do
    body = { 'hits' => [] }.to_json
    response = stub(success?: true, json: JSON.parse(body))
    http_client = mock('client')
    http_client.expects(:get)
               .with('https://weird.org/api/records?page=1&size=1')
               .returns(response)

    resolver = Repo::Resolvers::ZenodoResolver.new
    context = Repo::RepoResolverContext.new('https://weird.org/records/123', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://weird.org/records/123'

    resolver.resolve(context)

    assert_nil context.type
    assert_nil @repo_db.get('https://weird.org')
  end

  test 'resolve does not set type when API returns non-success status' do
    response = stub(success?: false, json: {}, status: 500)
    http_client = mock('client')
    http_client.expects(:get)
               .with('https://baddomain.org/api/records?page=1&size=1')
               .returns(response)
    resolver = Repo::Resolvers::ZenodoResolver.new
    context = Repo::RepoResolverContext.new('https://baddomain.org/records/123', http_client: http_client, repo_db: @repo_db)
    context.object_url = 'https://baddomain.org/records/123'
    resolver.resolve(context)
    assert_nil context.type
    assert_nil @repo_db.get('https://baddomain.org')
  end
end
