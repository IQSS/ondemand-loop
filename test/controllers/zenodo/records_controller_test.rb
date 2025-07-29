require 'test_helper'

class Zenodo::RecordsControllerTest < ActionDispatch::IntegrationTest
  include FileFixtureHelper

  def setup
    @record = OpenStruct.new(title: 'rec', files: [])
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(@record)
    Zenodo::ProjectService.any_instance.stubs(:initialize_project).returns(Project.new(name: 'P'))
    Zenodo::ProjectService.any_instance.stubs(:initialize_download_files).returns([])
  end

  test 'show renders success' do
    get view_zenodo_record_path('1')
    assert_response :success
  end

  test 'record view shows active project button text when project active' do
    @record = OpenStruct.new(title: 'rec', files: [OpenStruct.new(id: 1, filename: 'f.txt', filesize: 10)])
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(@record)
    user_settings_mock = mock('UserSettings')
    user_settings_mock.stubs(:user_settings).returns(OpenStruct.new(active_project: 'proj'))
    Current.stubs(:settings).returns(user_settings_mock)

    get view_zenodo_record_path('1')
    assert_response :success
    label = I18n.t('zenodo.records.record_files.button_add_files_active_project_text')
    title = I18n.t('zenodo.records.record_files.button_add_files_active_project_title')
    assert_select "input[type=submit][value='#{label}'][title='#{title}']", 1
  end

  test 'record view shows new project button text when no active project' do
    @record = OpenStruct.new(title: 'rec', files: [OpenStruct.new(id: 1, filename: 'f.txt', filesize: 10)])
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(@record)
    user_settings_mock = mock('UserSettings')
    user_settings_mock.stubs(:user_settings).returns(OpenStruct.new(active_project: nil))
    Current.stubs(:settings).returns(user_settings_mock)

    get view_zenodo_record_path('1')
    assert_response :success
    label = I18n.t('zenodo.records.record_files.button_add_files_new_project_text')
    title = I18n.t('zenodo.records.record_files.button_add_files_new_project_title')
    assert_select "input[type=submit][value='#{label}'][title='#{title}']", 1
  end

  test 'show redirects when not found' do
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(nil)
    get view_zenodo_record_path('1')
    assert_redirected_to root_path
  end

  test 'download initializes project when missing' do
    Project.stubs(:find).returns(nil)
    project = Project.new(name: 'P')
    project.stubs(:save).returns(true)
    Zenodo::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    post download_zenodo_record_files_path, params: {id: '1', file_ids: []}
    assert_redirected_to root_path
    assert_match 'Files added to project', flash[:notice]
  end

  test 'download reports project save error' do
    Project.stubs(:find).returns(nil)
    project = Project.new(name: 'P')
    project.stubs(:save).returns(false)
    project.errors.add(:base, 'fail')
    Zenodo::ProjectService.any_instance.stubs(:initialize_project).returns(project)
    post download_zenodo_record_files_path, params: {id: '1', file_ids: []}
    assert_redirected_to root_path
    assert_match 'fail', flash[:alert]
  end

  test 'download aborts on file validation error' do
    Project.stubs(:find).returns(Project.new(name: 'P'))
    invalid_file = OpenStruct.new(valid?: false, filename: 'f.txt', errors: OpenStruct.new(full_messages: ['bad']))
    Zenodo::ProjectService.any_instance.stubs(:initialize_download_files).returns([invalid_file])
    post download_zenodo_record_files_path, params: {id: '1', file_ids: []}
    assert_redirected_to root_path
    assert_match 'bad', flash[:alert]
  end
end
