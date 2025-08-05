require 'test_helper'

class Zenodo::Actions::DepositionsTest < ActiveSupport::TestCase
  def setup
    @action = Zenodo::Actions::Depositions.new('10')
    @repo_url = OpenStruct.new(server_url: 'https://zenodo.org')
  end

  test 'show loads deposition using repo db api key' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    service = mock('service')
    service.expects(:find_deposition).with('10').returns(:deposition)
    Zenodo::DepositionService.expects(:new).with('https://zenodo.org', api_key: 'KEY').returns(service)

    result = @action.show(repo_url: @repo_url)
    assert result.success?
  end

  test 'show returns error when api key missing' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: nil))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)

    result = @action.show(repo_url: @repo_url)
    refute result.success?
    assert_equal I18n.t('zenodo.depositions.message_api_key_required'), result.message[:alert]
  end
end
