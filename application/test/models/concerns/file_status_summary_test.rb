# frozen_string_literal: true

require 'test_helper'

class FileStatusSummaryTest < ActiveSupport::TestCase
  class DummyFile
    attr_reader :status

    def initialize(status)
      @status = status
    end
  end

  class DummyWithFileStatusSummary
    include FileStatusSummary

    def initialize(files)
      @files = files
    end

    def status_files
      @files
    end
  end

  test 'status_summary returns correct counts by status and total' do
    files = [
      DummyFile.new(FileStatus::PENDING),
      DummyFile.new(FileStatus::PENDING),
      DummyFile.new(FileStatus::SUCCESS),
      DummyFile.new(FileStatus::ERROR),
      DummyFile.new(FileStatus::ERROR),
      DummyFile.new(FileStatus::ERROR)
    ]

    dummy = DummyWithFileStatusSummary.new(files)
    summary = dummy.status_summary

    assert_equal 2, summary.pending
    assert_equal 1, summary.success
    assert_equal 3, summary.error
    assert_equal 6, summary.total
  end

  test 'status_summary returns total 0 when status_files is empty' do
    dummy = DummyWithFileStatusSummary.new([])
    summary = dummy.status_summary

    assert_equal 0, summary.total
  end

  test 'status_summary returns total 0 when status_files is nil' do
    dummy = DummyWithFileStatusSummary.new(nil)
    summary = dummy.status_summary

    assert_equal 0, summary.total
  end

  test 'status_summary returns 0 for statuses that are not present' do
    files = [
      DummyFile.new(FileStatus::SUCCESS),
      DummyFile.new(FileStatus::SUCCESS),
      DummyFile.new(FileStatus::CANCELLED)
    ]

    dummy = DummyWithFileStatusSummary.new(files)
    summary = dummy.status_summary

    assert_equal 2, summary.success
    assert_equal 1, summary.cancelled
    assert_equal 0, summary.pending
    assert_equal 0, summary.error
    assert_equal 3, summary.total
  end
end
