require 'test_helper'

class Repo::Resolvers::CacheResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @repo_db_temp = Tempfile.new('repo_db')
    @repo_db = Repo::RepoDb.new(db_path: @repo_db_temp.path)
  end

  def teardown
    @repo_db_temp.unlink
  end

  test 'resolve sets type from cache when entry exists' do
    @repo_db.set('https://zenodo.org', type: ConnectorType::ZENODO, metadata: {})

    resolver = Repo::Resolvers::CacheResolver.new
    context = Repo::RepoResolverContext.new('https://zenodo.org/records/123', repo_db: @repo_db)
    context.object_url = 'https://zenodo.org/records/123'

    resolver.resolve(context)

    assert_equal ConnectorType::ZENODO, context.type
  end

  test 'resolve leaves type nil when cache miss' do
    resolver = Repo::Resolvers::CacheResolver.new
    context = Repo::RepoResolverContext.new('https://unknown.org/records/123', repo_db: @repo_db)
    context.object_url = 'https://unknown.org/records/123'

    resolver.resolve(context)

    assert_nil context.type
  end

  test 'resolve is no-op when object_url missing' do
    resolver = Repo::Resolvers::CacheResolver.new
    context = Repo::RepoResolverContext.new('https://zenodo.org/records/123', repo_db: @repo_db)
    resolver.resolve(context)
    assert_nil context.type
  end

  test 'resolve ignores invalid object_url' do
    @repo_db.set('https://zenodo.org', type: ConnectorType::ZENODO, metadata: {})
    resolver = Repo::Resolvers::CacheResolver.new
    context = Repo::RepoResolverContext.new('bad', repo_db: @repo_db)
    context.object_url = 'not a url'
    resolver.resolve(context)
    assert_nil context.type
  end
end
