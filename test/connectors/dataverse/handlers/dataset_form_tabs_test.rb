require 'test_helper'

class Dataverse::Handlers::DatasetFormTabsTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @bundle = create_upload_bundle(create_project)
    @action = Dataverse::Handlers::DatasetFormTabs.new
  end

  test 'params schema is empty' do
    assert_empty @action.params_schema
  end

  test 'edit returns tabs form partial' do
    @action.stubs(:datasets).returns(OpenStruct.new(items: []))
    @action.stubs(:subjects).returns([])
    @action.stubs(:profile).returns(nil)
    result = @action.edit(@bundle, {})
    assert_equal '/connectors/dataverse/dataset_form_tabs', result.template
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
    ::Configuration.repo_db.stubs(:get).with('https://demo.dv').returns(repo)
    ::Configuration.repo_db.stubs(:update)

    md_service = mock('md')
    md_service.expects(:get_citation_metadata).returns(OpenStruct.new(subjects: ['Bio']))
    Dataverse::MetadataService.stubs(:new).returns(md_service)

    result = @action.send(:subjects, @bundle)
    assert_includes result, 'Bio'
  end

  test 'subjects uses cached subjects when present' do
    meta = OpenStruct.new(dataverse_url: 'https://demo.dv', server_domain: 'demo.dv')
    @bundle.stubs(:connector_metadata).returns(meta)

    repo = mock('repo')
    repo.stubs(:metadata).returns(OpenStruct.new(subjects: ['Chem']))
    ::Configuration.repo_db.stubs(:get).with('https://demo.dv').returns(repo)
    ::Configuration.repo_db.expects(:update).never
    Dataverse::MetadataService.expects(:new).never

    result = @action.send(:subjects, @bundle)
    assert_equal ['Chem'], result
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
