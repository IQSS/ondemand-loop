require 'test_helper'

class Zenodo::Handlers::ConnectorEditTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @bundle.stubs(:connector_metadata).returns(OpenStruct.new(server_domain: 'host'))
    @action = Zenodo::Handlers::ConnectorEdit.new
  end

  test 'params schema includes expected keys' do
    assert_includes @action.params_schema, :api_key
    assert_includes @action.params_schema, :key_scope
  end

  test 'edit returns connector form' do
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/zenodo/connector_edit_form', result.template
  end

  test 'update saves api key in repo' do
    RepoRegistry.repo_db.stubs(:update)
    result = @action.update(@bundle, {api_key: 'KEY', key_scope: 'server'})
    assert result.success?
  end

  test 'update saves api key in bundle' do
    meta = {}
    @bundle.stubs(:metadata).returns(meta)
    result = @action.update(@bundle, {api_key: 'B', key_scope: 'bundle'})
    assert result.success?
    assert_equal 'B', meta[:auth_key]
  end
end
