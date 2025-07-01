# frozen_string_literal: true
require 'test_helper'

class WidgetsControllerTest < ActionDispatch::IntegrationTest
  test 'should return 400 for invalid widget path' do
    get widgets_path(widget_path: '../etc/passwd')
    assert_response :bad_request
    assert_includes @response.body, '400 Bad Request'
  end

  test 'should return 400 for possible hacks' do
    get widgets_path(widget_path: '$HOME/private/file')
    assert_response :bad_request
    assert_includes @response.body, '400 Bad Request'
  end

  test 'should return 404 for non-existent widget' do
    get widgets_path(widget_path: 'nonexistent_widget')
    assert_response :not_found
    assert_includes @response.body, '404 Widget not found'
  end

  test 'should render existing widget partial' do
    get widgets_path(widget_path: 'widgets_controller_test')
    assert_response :success
    assert_includes @response.body, 'Test Widget'
  end
end
