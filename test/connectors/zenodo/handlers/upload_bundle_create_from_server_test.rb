require 'test_helper'

class Zenodo::Handlers::UploadBundleCreateFromServerTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @action = Zenodo::Handlers::UploadBundleCreateFromServer.new
    ::Configuration.repo_history.stubs(:add_repo)
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :object_url
  end

  test 'create handles generic zenodo url' do
    url_data = OpenStruct.new(deposition?: false, record?: false, domain: 'zenodo.org',
                              zenodo_url: 'https://zenodo.org', record_id: nil, deposition_id: nil)
    Zenodo::ZenodoUrl.stubs(:parse).returns(url_data)

    Common::FileUtils.any_instance.stubs(:normalize_name).returns('bundle')
    UploadBundle.any_instance.stubs(:save)

    result = @action.create(@project, object_url: 'https://zenodo.org/about')
    assert result.success?
    assert_equal 'zenodo.org', result.resource.name
    assert_equal 'https://zenodo.org', result.resource.metadata[:zenodo_url]
    assert_nil result.resource.metadata[:record_id]
    assert_nil result.resource.metadata[:deposition_id]
  end

  end
