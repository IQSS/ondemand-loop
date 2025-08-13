require 'test_helper'

class Dataverse::RepositorySettingsProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Dataverse::RepositorySettingsProcessor.new
    @tempfile = Tempfile.new('repo_db')
    RepoRegistry.repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    RepoRegistry.repo_db.set('https://demo.org', type: ConnectorType::DATAVERSE)
  end

  def teardown
    @tempfile.unlink
  end

  test 'params schema includes repo_url and auth_key' do
    assert_includes @processor.params_schema, :repo_url
    assert_includes @processor.params_schema, :auth_key
  end

  test 'update stores key and returns message' do
    repo = RepoRegistry.repo_db.get('https://demo.org')
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: 'k' })
    assert_equal 'k', RepoRegistry.repo_db.get('https://demo.org').metadata.auth_key
    assert_equal({ notice: I18n.t('connectors.dataverse.handlers.repository_settings_update.message_success', url: 'https://demo.org', type: repo.type) }, result.message)
  end
end
