require 'test_helper'

class Dataverse::Actions::DatasetFormTabsTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Dataverse::Actions::DatasetFormTabs.new
  end

  test 'edit returns tabs form partial' do
    @action.stubs(:datasets).returns([])
    @action.stubs(:subjects).returns([])
    @action.stubs(:profile).returns(nil)
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/dataset_form_tabs', result.partial
  end

  test 'update not implemented' do
    assert_raises(NotImplementedError) { @action.update(@bundle, {}) }
  end

  test 'datasets fetches via collections service' do
    meta = OpenStruct.new(dataverse_url: 'https://demo.dv', api_key: mock({value: '12345'}), collection_id: '12345')
    @bundle.stubs(:connector_metadata).returns(meta)

    collections_service = mock('collections')
    collections_service.expects(:search_collection_items).returns(Dataverse::SearchResponse.new({}.to_json))
    Dataverse::CollectionService.stubs(:new).returns(collections_service)

    result = @action.send(:datasets, @bundle)
    assert_instance_of Dataverse::SearchResponse::Data, result
    assert_equal result.items, []
  end

  test 'subjects fetches and caches when missing' do
    meta = OpenStruct.new(dataverse_url: 'https://demo.dv', server_domain: 'demo.dv')
    @bundle.stubs(:connector_metadata).returns(meta)
    repo = mock('repo')
    repo.stubs(:metadata).returns(OpenStruct.new(subjects: nil))
    RepoRegistry.repo_db.stubs(:get).with('demo.dv').returns(repo)
    RepoRegistry.repo_db.stubs(:update)

    md_service = mock('md')
    md_service.expects(:get_citation_metadata).returns(OpenStruct.new(subjects: ['Bio']))
    Dataverse::MetadataService.stubs(:new).returns(md_service)

    result = @action.send(:subjects, @bundle)
    assert_includes result, 'Bio'
  end

  test 'profile fetched via user service' do
    meta = OpenStruct.new(dataverse_url: 'https://demo.dv', api_key: OpenStruct.new(value: 'k'))
    @bundle.stubs(:connector_metadata).returns(meta)

    user_data = Dataverse::UserProfileResponse.new({}.to_json)
    user_service = mock('service')
    user_service.expects(:get_user_profile).returns(user_data)
    Dataverse::UserService.stubs(:new).returns(user_service)

    assert_equal user_data, @action.send(:profile, @bundle)
  end
end
