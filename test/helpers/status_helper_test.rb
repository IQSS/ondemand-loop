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

  test 'retry_button_visible? is true when restart is possible' do
    project = create_project
    file = create_download_file(project)
    file.status = FileStatus::CANCELLED
    file.metadata = { partial_downloads: true }
    assert retry_button_visible?(file)

    file.status = FileStatus::ERROR
    file.metadata = { partial_downloads: nil }
    assert retry_button_visible?(file)
  end

  test 'retry_button_visible? is false when status does not allow retry or partial downloads disabled' do
    project = create_project
    file = create_download_file(project)
    file.status = FileStatus::SUCCESS
    file.metadata = { partial_downloads: true }
    refute retry_button_visible?(file)

    file.status = FileStatus::CANCELLED
    file.metadata = { partial_downloads: false }
    refute retry_button_visible?(file)
  end
end
