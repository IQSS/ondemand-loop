# frozen_string_literal: true
require 'test_helper'

class RepositorySettingsHelperTest < ActionView::TestCase
  include RepositorySettingsHelper

  test 'browse_repository_path resolves url via dispatcher' do
    entry = OpenStruct.new(type: 'zenodo')
    result = OpenStruct.new(redirect_url: '/path')
    resolver = mock('Resolver')
    resolver.expects(:get_controller_url).with('https://demo.org').returns(result)
    ConnectorClassDispatcher.stubs(:repo_controller_resolver).with('zenodo').returns(resolver)

    assert_equal '/path', browse_repository_path('https://demo.org', entry)
  end

  test 'repo_api_key? returns true only when auth_key exists' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'secret'))
    ::Configuration.stubs(:repo_db).returns(stub(get: repo_info))
    assert repo_api_key?('https://demo.org')

    ::Configuration.stubs(:repo_db).returns(stub(get: nil))
    refute repo_api_key?('https://demo.org')
  end
end
