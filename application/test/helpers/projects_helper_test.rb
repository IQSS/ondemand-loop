# frozen_string_literal: true
require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ProjectsHelper

  setup do
    @original_settings = Current.settings
  end

  teardown do
    Current.settings = @original_settings
  end

  test 'header and border classes respond to active' do
    assert_equal 'bg-primary-subtle', project_header_class(true)
    assert_equal 'bg-body-secondary', project_header_class(false)
    assert_equal 'border-primary-subtle', project_border_class(true)
    assert_equal '', project_border_class(false)
  end

  test 'project_progress_data compiles counts' do
    summary = OpenStruct.new(pending: 1, downloading: 2, uploading: 1, success: 3, cancelled: 1, error: 0, total: 8)
    data = project_progress_data(summary, 't')
    assert_equal 't', data[:title]
    assert_equal 1, data[:pending]
    assert_equal 3, data[:in_progress]
    assert_equal 3, data[:completed]
    assert_equal 1, data[:cancelled]
    assert_equal 0, data[:error]
    assert_equal 8, data[:total]
    assert_not_nil data[:id]
  end

  test 'active_project? returns true if ids match' do
    Current.settings = OpenStruct.new(user_settings: OpenStruct.new(active_project: '123'))
    assert active_project?('123')
  end

  test 'active_project? returns false if ids do not match' do
    Current.settings = OpenStruct.new(user_settings: OpenStruct.new(active_project: '123'))
    refute active_project?('456')
  end

  test 'select_project_list moves active project to top' do
    project1 = OpenStruct.new(id: 1, name: 'Project A')
    project2 = OpenStruct.new(id: 2, name: 'Project B')
    Project.stubs(:all).returns([project1, project2])
    Current.settings = OpenStruct.new(user_settings: OpenStruct.new(active_project: '2'))

    result = select_project_list

    assert_equal [project2, project1], result
  end

  test 'select_project_list returns original order if no active match' do
    project1 = OpenStruct.new(id: 1, name: 'Project A')
    project2 = OpenStruct.new(id: 2, name: 'Project B')
    Project.stubs(:all).returns([project1, project2])
    Current.settings = OpenStruct.new(user_settings: OpenStruct.new(active_project: '999'))

    result = select_project_list

    assert_equal [project1, project2], result
  end

  test 'select_project_list returns original order if no active project set' do
    project1 = OpenStruct.new(id: 1, name: 'Project A')
    project2 = OpenStruct.new(id: 2, name: 'Project B')
    Project.stubs(:all).returns([project1, project2])
    Current.settings = OpenStruct.new(user_settings: OpenStruct.new(active_project: nil))

    result = select_project_list

    assert_equal [project1, project2], result
  end

  test 'project_download_dir_browser_id returns id string' do
    project = OpenStruct.new(id: 42)
    assert_equal 'download-dir-browser-42', project_download_dir_browser_id(project)
  end
end

