# frozen_string_literal: true
require 'test_helper'

class StatusHelperTest < ActionView::TestCase
  include StatusHelper

  test 'cancel_button_disabled? should be true for these statuses' do
    [FileStatus::SUCCESS, FileStatus::ERROR, FileStatus::CANCELLED].each do |status|
      assert cancel_button_disabled?(status)
    end
  end

  test 'cancel_button_disabled should be false for these statuses' do
    [FileStatus::PENDING, FileStatus::DOWNLOADING, FileStatus::UPLOADING].each do |status|
      refute cancel_button_disabled?(status)
    end
  end

  test 'retry_button_visible? is true when file status does allow retry' do
    project = create_project
    file = create_download_file(project)
    file.status = FileStatus::CANCELLED
    assert retry_button_visible?(file)

    file.status = FileStatus::ERROR
    assert retry_button_visible?(file)

    file.status = FileStatus::CANCELLED
    assert retry_button_visible?(file)
  end

  test 'retry_button_visible? is false when file status does not allow retry' do
    project = create_project
    file = create_download_file(project)
    file.status = FileStatus::SUCCESS
    refute retry_button_visible?(file)

    file.status = FileStatus::DOWNLOADING
    refute retry_button_visible?(file)

    file.status = FileStatus::UPLOADING
    refute retry_button_visible?(file)
  end
end
