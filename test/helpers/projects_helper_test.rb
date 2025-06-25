# frozen_string_literal: true
require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ProjectsHelper

  test 'header and border classes respond to active' do
    assert_equal 'bg-primary-subtle', project_header_class(true)
    assert_equal 'bg-body-secondary', project_header_class(false)
    assert_equal 'border-primary-subtle', project_border_class(true)
    assert_equal '', project_border_class(false)
  end

  test 'project_progress_data compiles counts' do
    summary = OpenStruct.new(pending: 1, downloading: 2, success: 3, cancelled: 1, error: 0, total: 7)
    data = project_progress_data(summary, 't')
    assert_equal 't', data[:title]
    assert_equal 3, data[:pending]
    assert_equal 3, data[:completed]
    assert_equal 1, data[:cancelled]
    assert_equal 0, data[:error]
    assert_equal 7, data[:total]
    assert_not_nil data[:id]
  end
end
