require 'test_helper'

class Dataverse::RepositorySettingsProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Dataverse::RepositorySettingsProcessor.new
    @tempfile = Tempfile.new('repo_db')
    repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    ::Configuration.stubs(:repo_db).returns(repo_db)
    repo_db.set('https://demo.org', type: ConnectorType::DATAVERSE)
  end

  def teardown
    @tempfile.unlink
  end

  test 'params schema includes repo_url and auth_key' do
    assert_includes @processor.params_schema, :repo_url
    assert_includes @processor.params_schema, :auth_key
  end

  test 'update stores key and returns message' do
    repo = ::Configuration.repo_db.get('https://demo.org')
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: 'k' })
    assert_equal 'k', ::Configuration.repo_db.get('https://demo.org').metadata.auth_key
    assert_equal({ notice: I18n.t('connectors.dataverse.handlers.repository_settings_update.message_success', url: 'https://demo.org', type: repo.type) }, result.message)
  end

  test 'update returns ConnectorResult with success true' do
    repo = ::Configuration.repo_db.get('https://demo.org')
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: 'test-key' })

    assert_instance_of ConnectorResult, result
    assert result.success?
    assert_not_nil result.message
    assert_includes result.message.keys, :notice
  end

  test 'update handles different auth key values' do
    repo = ::Configuration.repo_db.get('https://demo.org')

    # Test with empty string
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: '' })
    updated_repo = ::Configuration.repo_db.get('https://demo.org')
    assert_equal '', updated_repo.metadata&.auth_key || ''
    assert result.success?

    # Test with long auth key
    long_key = 'a' * 100
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: long_key })
    updated_repo = ::Configuration.repo_db.get('https://demo.org')
    assert_equal long_key, updated_repo.metadata.auth_key
    assert result.success?

    # Test with special characters
    special_key = 'key!@#$%^&*()_+'
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: special_key })
    updated_repo = ::Configuration.repo_db.get('https://demo.org')
    assert_equal special_key, updated_repo.metadata.auth_key
    assert result.success?
  end

  test 'update message includes correct URL and type' do
    repo = ::Configuration.repo_db.get('https://demo.org')
    result = @processor.update(repo, { repo_url: 'https://demo.org', auth_key: 'test-key' })

    message = result.message[:notice]
    assert_match(/https:\/\/demo\.org/, message)
    assert_match(/#{repo.type}/, message)
  end

  test 'initialize can accept nil parameter' do
    processor = Dataverse::RepositorySettingsProcessor.new(nil)
    assert_not_nil processor
    assert_equal [:repo_url, :auth_key], processor.params_schema
  end

  test 'initialize can accept any object parameter' do
    processor = Dataverse::RepositorySettingsProcessor.new("some object")
    assert_not_nil processor
    assert_equal [:repo_url, :auth_key], processor.params_schema
  end
end
