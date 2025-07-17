require 'test_helper'

class Repo::Resolvers::ZenodoResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @repo_db = Repo::RepoDb.new(db_path: Tempfile.new('db').path)
    @resolver = Repo::Resolvers::ZenodoResolver.new
  end

  test 'resolve sets type when url matches' do
    context = Repo::RepoResolverContext.new('https://zenodo.org/records/1', repo_db: @repo_db)
    context.object_url = 'https://zenodo.org/records/1'
    @resolver.resolve(context)
    assert_equal ConnectorType::ZENODO, context.type
    assert @repo_db.get('https://zenodo.org')
  end

  test 'resolve ignores unknown domain' do
    context = Repo::RepoResolverContext.new('https://example.com/1', repo_db: @repo_db)
    context.object_url = 'https://example.com/1'
    @resolver.resolve(context)
    assert_nil context.type
  end
end
