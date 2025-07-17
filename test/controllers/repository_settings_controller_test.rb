require "test_helper"
require Rails.root.join('app/services/repo/repo_resolver_context')

class RepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tempfile = Tempfile.new('repo_db')
    RepoRegistry.repo_db = Repo::RepoDb.new(db_path: @tempfile.path)
    RepoRegistry.repo_db.set('https://demo.org', type: ConnectorType::DATAVERSE, metadata: {auth_key: 'old'})
  end

  def teardown
    @tempfile.unlink
  end

  test 'index should render' do
    get repository_settings_url
    assert_response :success
  end

  test 'create should return success when URL resolved' do
    resolver = mock('resolver')
    response = Repo::RepoResolverResponse.new('https://zenodo.org/', ConnectorType::ZENODO)
    resolver.stubs(:resolve).with('https://zenodo.org/').returns(response)
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post repository_settings_url, params: { repo_url: 'https://zenodo.org/' }

    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.create.message_success', url: 'https://zenodo.org/', type: 'zenodo'), flash[:notice]
  end

  test 'create should show error on unknown repository' do
    resolver = mock('resolver')
    response = Repo::RepoResolverResponse.new('u', nil)
    resolver.stubs(:resolve).with('u').returns(response)
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post repository_settings_url, params: { repo_url: 'u' }

    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.create.message_invalid_url', url: 'u'), flash[:alert]
  end

  test 'update delegates to processor' do
    repo = RepoRegistry.repo_db.get('https://demo.org')
    processor = mock('processor')
    ConnectorClassDispatcher.stubs(:repository_settings_processor).with(repo.type).returns(processor)
    processor.stubs(:params_schema).returns([:repo_url, :auth_key])
    processor.expects(:update).with(repo, { 'repo_url' => 'https://demo.org', 'auth_key' => 'new' }).returns(ConnectorResult.new(message: { notice: 'ok' }, success: true))

    put repository_settings_url, params: { repo_url: 'https://demo.org', auth_key: 'new' }
    assert_redirected_to repository_settings_url
    assert_equal 'ok', flash[:notice]
  end

  test 'update should show error when repository missing' do
    put repository_settings_url, params: { repo_url: 'missing.org', auth_key: 'x' }
    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.update.message_not_found', domain: 'missing.org'), flash[:alert]
  end

  test 'destroy should delete repository' do
    delete repository_settings_url, params: { repo_url: 'https://demo.org' }
    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.destroy.message_deleted', domain: 'https://demo.org', type: 'dataverse'), flash[:notice]
    assert_nil RepoRegistry.repo_db.get('https://demo.org')
  end

  test 'destroy should show error when repository missing' do
    delete repository_settings_url, params: { repo_url: 'missing.org' }
    assert_redirected_to repository_settings_url
    assert_equal I18n.t('repository_settings.destroy.message_not_found', domain: 'missing.org'), flash[:alert]
  end
end
