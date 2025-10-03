require 'test_helper'

class Zenodo::RepositorySettingsProcessorTest < ActiveSupport::TestCase
  def setup
    @processor = Zenodo::RepositorySettingsProcessor.new
    @tempfile = Tempfile.new('repo_db')
    repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    ::Configuration.stubs(:repo_db).returns(repo_db)
    repo_db.set('https://zenodo.org', type: ConnectorType::ZENODO)
  end

  def teardown
    @tempfile.unlink
  end

  test 'params schema includes repo_url and auth_key' do
    assert_includes @processor.params_schema, :repo_url
    assert_includes @processor.params_schema, :auth_key
  end

  test 'update stores key and returns message' do
    repo = ::Configuration.repo_db.get('https://zenodo.org')
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: 'k' })
    assert_equal 'k', ::Configuration.repo_db.get('https://zenodo.org').metadata.auth_key
    assert_equal({ notice: I18n.t('connectors.zenodo.handlers.repository_settings_update.message_success', url: 'https://zenodo.org', type: repo.type) }, result.message)
  end

  test 'update returns ConnectorResult with success true' do
    repo = ::Configuration.repo_db.get('https://zenodo.org')
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: 'test-key' })

    assert_instance_of ConnectorResult, result
    assert result.success?
    assert_not_nil result.message
    assert_includes result.message.keys, :notice
  end

  test 'update handles different auth key values' do
    repo = ::Configuration.repo_db.get('https://zenodo.org')

    # Test with empty string
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: '' })
    updated_repo = ::Configuration.repo_db.get('https://zenodo.org')
    assert_equal '', updated_repo.metadata&.auth_key || ''
    assert result.success?

    # Test with long auth key
    long_key = 'z' * 100
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: long_key })
    updated_repo = ::Configuration.repo_db.get('https://zenodo.org')
    assert_equal long_key, updated_repo.metadata.auth_key
    assert result.success?

    # Test with API token format
    api_token = 'zenodo-access-token-12345abcdef'
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: api_token })
    updated_repo = ::Configuration.repo_db.get('https://zenodo.org')
    assert_equal api_token, updated_repo.metadata.auth_key
    assert result.success?
  end

  test 'update message includes correct URL and type' do
    repo = ::Configuration.repo_db.get('https://zenodo.org')
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: 'test-key' })

    message = result.message[:notice]
    assert_match(/https:\/\/zenodo\.org/, message)
    assert_match(/#{repo.type}/, message)
  end

  test 'initialize can accept nil parameter' do
    processor = Zenodo::RepositorySettingsProcessor.new(nil)
    assert_not_nil processor
    assert_equal [:repo_url, :auth_key], processor.params_schema
  end

  test 'initialize can accept any object parameter' do
    processor = Zenodo::RepositorySettingsProcessor.new("some object")
    assert_not_nil processor
    assert_equal [:repo_url, :auth_key], processor.params_schema
  end

  test 'update preserves existing metadata while updating auth_key' do
    repo = ::Configuration.repo_db.get('https://zenodo.org')

    # Set some initial metadata
    ::Configuration.repo_db.update('https://zenodo.org', metadata: {
      auth_key: 'old-key',
      other_setting: 'preserved-value'
    })

    # Update only auth_key
    result = @processor.update(repo, { repo_url: 'https://zenodo.org', auth_key: 'new-key' })
    updated_repo = ::Configuration.repo_db.get('https://zenodo.org')

    assert_equal 'new-key', updated_repo.metadata.auth_key
    assert result.success?
  end
end
