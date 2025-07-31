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

  test 'record view shows project selection dropdown and disabled submit button' do
    @record = OpenStruct.new(title: 'rec', files: [OpenStruct.new(id: 1, filename: 'f.txt', filesize: 10)])
    Zenodo::RecordService.any_instance.stubs(:find_record).returns(@record)

    get view_zenodo_record_path('1')
    assert_response :success
    assert_select "select#project_select", 1
    assert_select "button#files_submit[disabled]", 1
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
