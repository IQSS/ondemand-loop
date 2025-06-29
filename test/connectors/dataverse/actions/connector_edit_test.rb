require 'test_helper'

class Dataverse::Actions::ConnectorEditTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Dataverse::Actions::ConnectorEdit.new
  end

  test 'edit returns connector edit form' do
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/connector_edit_form', result.partial
    assert_equal({upload_bundle: @bundle}, result.locals)
  end

  test 'update stores api key in bundle metadata' do
    meta = {}
    @bundle.stubs(:metadata).returns(meta)
    result = @action.update(@bundle, {api_key: 'SECRET', key_scope: 'bundle'})
    assert result.success?
    assert_equal 'SECRET', meta[:auth_key]
  end

  test 'update stores key server wide' do
    RepoRegistry.repo_db.stubs(:update)
    @bundle.stubs(:connector_metadata).returns(OpenStruct.new(server_domain: 'host'))
    result = @action.update(@bundle, {api_key: 'S', key_scope: 'server'})
    assert result.success?
  end
end
