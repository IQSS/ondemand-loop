require 'test_helper'

class Dataverse::Actions::DatasetCreateTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    meta = OpenStruct.new(dataverse_url: 'http://dv.org', api_key: OpenStruct.new(value: 'KEY'), collection_id: 'COL1')
    @bundle.stubs(:connector_metadata).returns(meta)
    @action = Dataverse::Actions::DatasetCreate.new
  end

  test 'edit returns dataset create form' do
    user_service = mock('service'); user_service.stubs(:get_user_profile).returns(Dataverse::UserProfileResponse.new({}.to_json))
    Dataverse::UserService.stubs(:new).returns(user_service)
    metadata_service = mock('meta'); metadata_service.stubs(:get_citation_metadata).returns(OpenStruct.new(subjects: []))
    Dataverse::MetadataService.stubs(:new).returns(metadata_service)
    RepoRegistry.stubs(:repo_db).returns(stub(get: OpenStruct.new(metadata: OpenStruct.new(subjects: nil)), update: true))
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/dataset_create_form', result.partial
  end

  test 'update stores dataset metadata' do
    ds_service = mock('ds'); ds_service.stubs(:create_dataset).returns(OpenStruct.new(persistent_id: 'pid', id: 1))
    Dataverse::DatasetService.stubs(:new).returns(ds_service)
    result = @action.update(@bundle, {title: 'Title', author: 'A', description: '', contact_email: '', subject: 's'})
    assert result.success?
    assert_equal 'pid', @bundle.metadata[:dataset_id]
  end
end
