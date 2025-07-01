# frozen_string_literal: true
require 'test_helper'

class DetachedProcessHelperTest < ActionView::TestCase
  include DetachedProcessHelper

  test 'process_status_class for idle download' do
    status = OpenStruct.new(idle?: true)
    info = process_status_class(status, type: :download)
    assert_equal 'btn-outline-warning', info.button
    assert_equal 'bi-arrow-down-circle', info.icon
    assert_equal 'text-warning-emphasis', info.text
  end

  test 'process_status_class for active upload' do
    status = OpenStruct.new(idle?: false)
    info = process_status_class(status, type: :upload)
    assert_equal 'btn-outline-info', info.button
    assert_equal 'bi-arrow-up-circle-fill', info.icon
    assert_equal 'text-info pulse', info.text
  end
end
