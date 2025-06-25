# frozen_string_literal: true
require 'test_helper'

class DownloadStatusHelperTest < ActionView::TestCase
  include DownloadStatusHelper

  test 'cancel_button_class disabled for completed' do
    assert_equal 'disabled', cancel_button_class(FileStatus::SUCCESS)
  end

  test 'cancel_button_class empty for pending' do
    assert_equal '', cancel_button_class(FileStatus::PENDING)
  end
end
