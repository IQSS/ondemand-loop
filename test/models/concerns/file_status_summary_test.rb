# frozen_string_literal: true

require 'test_helper'

class FileStatusSummaryTest < ActiveSupport::TestCase

  class DummyWithFileStatusSummary
    include FileStatusSummary

    def initialize(files)
      @files = files
    end

    def status_files
      @files
    end
  end

  def update_file(file, status:, start_date: nil, end_date: nil)
    file.status = status
    file.start_date = start_date
    file.end_date = end_date
    file
  end

  test 'status_summary returns correct counts, elapsed, and date range' do
    project = create_project
    bundle = create_upload_bundle(project)

    files = [
      update_file(create_upload_file(project, bundle), status: FileStatus::PENDING),
      update_file(create_upload_file(project, bundle), status: FileStatus::SUCCESS),
      update_file(create_upload_file(project, bundle), status: FileStatus::SUCCESS, start_date: '2025-06-01T12:00:00', end_date: '2025-06-01T12:30:00'),
      update_file(create_upload_file(project, bundle), status: FileStatus::ERROR, start_date: '2025-06-02T09:00:00', end_date: '2025-06-02T10:00:00')
    ]

    dummy = DummyWithFileStatusSummary.new(files)
    summary = dummy.status_summary

    assert_equal 1, summary.pending
    assert_equal 2, summary.success
    assert_equal 1, summary.error
    assert_equal 0, summary.cancelled
    assert_equal 0, summary.downloading
    assert_equal 4, summary.total
    assert_equal '01:30:00', summary.elapsed
    assert_equal '2025-06-01T12:00:00', summary.start_date
    assert_equal '2025-06-02T10:00:00', summary.end_date
  end

  test 'status_summary returns total 0 when status_files is empty' do
    dummy = DummyWithFileStatusSummary.new([])
    summary = dummy.status_summary

    assert_equal 0, summary.total
    FileStatus::STATUS.each { |status| assert_equal 0, summary[status] }
    assert_equal '00:00:00', summary.elapsed
    assert_nil summary.start_date
    assert_nil summary.end_date
  end

  test 'status_summary returns total 0 when status_files is nil' do
    dummy = DummyWithFileStatusSummary.new(nil)
    summary = dummy.status_summary

    assert_equal 0, summary.total
    FileStatus::STATUS.each { |status| assert_equal 0, summary[status] }
    assert_equal '00:00:00', summary.elapsed
    assert_nil summary.start_date
    assert_nil summary.end_date
  end
end
