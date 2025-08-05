require "test_helper"

class ExploreControllerTest < ActionDispatch::IntegrationTest
  test 'should render placeholder template with notice' do
    get explore_url(
      connector_type: 'dataverse',
      server_domain: 'dataverse.harvard.edu',
      object_type: 'dataverse',
      object_id: 'harvard'
    )

    assert_response :success
    assert_select 'div.alert-info'
  end

  test 'zenodo landing action delegates to search service' do
    service = mock
    service.expects(:search)
           .with('test', page: 1)
           .returns(OpenStruct.new(items: []))
    Zenodo::SearchService.expects(:new)
                          .with('https://zenodo.org')
                          .returns(service)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'actions',
      object_id: 'landing',
      query: 'test'
    )

    assert_response :success
  end

  test 'redirects when repo url is invalid' do
    get '/explore/zenodo/%20/actions/landing'

    assert_redirected_to root_path
    assert_equal I18n.t('explore.show.message_invalid_repo_url', repo_url: ''), flash[:alert]
  end

  test 'zenodo records action renders record view' do
    record = OpenStruct.new(id: '1', title: 'rec', files: [])
    Zenodo::RecordService.any_instance.expects(:find_record).with('1').returns(record)
    user_settings_mock = mock('UserSettings')
    user_settings_mock.stubs(:user_settings).returns(OpenStruct.new(active_project: nil))
    Current.stubs(:settings).returns(user_settings_mock)

    get explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'records',
      object_id: '1'
    )

    assert_response :success
    assert_select 'h2', text: 'rec'
  end

  test 'zenodo records download redirects with notice' do
    record = OpenStruct.new(id: '1', title: 'rec', files: [])
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(record)
    Project.stubs(:find).returns(nil)
    project = Project.new(name: 'P')
    project.stubs(:save).returns(true)
    Zenodo::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    Zenodo::ProjectService.any_instance.stubs(:create_files_from_record).returns([])

    post explore_url(
      connector_type: 'zenodo',
      server_domain: 'zenodo.org',
      object_type: 'records',
      object_id: '1'
    )

    assert_redirected_to root_path
    assert_equal I18n.t('zenodo.records.download.message_success', project_name: 'P'), flash[:notice]
  end
end
