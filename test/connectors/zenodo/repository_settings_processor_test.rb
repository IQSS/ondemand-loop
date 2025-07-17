require 'test_helper'

class Zenodo::RepositorySettingsProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Zenodo::RepositorySettingsProcessor.new
    @tempfile = Tempfile.new('repo_db')
    RepoRegistry.repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    RepoRegistry.repo_db.set('https://zenodo.org', type: ConnectorType::ZENODO)
  end

  def teardown
    @tempfile.unlink
  end

  test 'params schema includes repo_url and auth_key' do
    assert_includes @processor.params_schema, :repo_url
    assert_includes @processor.params_schema, :auth_key
  end

  test 'update stores key and returns message' do
    repo = RepoRegistry.repo_db.get('https://zenodo.org')
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: 'k' })
    assert_equal 'k', RepoRegistry.repo_db.get('https://zenodo.org').metadata.auth_key
    assert_equal({ notice: I18n.t('connectors.zenodo.actions.repository_settings_update.message_success', url: 'https://zenodo.org', type: repo.type) }, result.message)
  end
end
