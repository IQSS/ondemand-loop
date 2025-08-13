# frozen_string_literal: true
require 'test_helper'

class FileStatusTest < ActiveSupport::TestCase

  test 'should raise error for invalid status' do
    assert_raises(ArgumentError, 'Invalid status: invalid_status') do
      FileStatus.get('invalid_status')
    end
  end

  test 'should initialize with a valid status' do
    status = FileStatus.get('pending')
    assert_equal 'pending', status.to_s
  end

  test 'should return correct status using dynamic methods' do
    status = FileStatus.get('pending')
    assert status.pending?
    refute status.downloading?
    refute status.success?
    refute status.error?
    refute status.cancelled?

    status = FileStatus.get('downloading')
    assert status.downloading?
    refute status.pending?
    refute status.success?
    refute status.error?
    refute status.cancelled?
  end

  test 'should be able to check different statuses' do
    status = FileStatus.get('success')
    assert status.success?
    refute status.pending?
    refute status.downloading?
    refute status.error?
    refute status.cancelled?

    status = FileStatus.get('error')
    assert status.error?
    refute status.pending?
    refute status.downloading?
    refute status.success?
    refute status.cancelled?

    status = FileStatus.get('cancelled')
    assert status.cancelled?
    refute status.pending?
    refute status.downloading?
    refute status.success?
    refute status.error?
  end

  test 'should not be case sensitive' do
    status = FileStatus.get('SUCCESS')
    assert status.success?

    status = FileStatus.get('DownLoading')
    assert status.downloading?

    status = FileStatus.get('PENDING')
    assert status.pending?
  end

  test 'should have constants for each status' do
    assert_instance_of FileStatus, FileStatus::PENDING
    assert_equal 'pending', FileStatus::PENDING.to_s
    assert_instance_of FileStatus, FileStatus::DOWNLOADING
    assert_equal 'downloading', FileStatus::DOWNLOADING.to_s
    assert_instance_of FileStatus, FileStatus::SUCCESS
    assert_equal 'success', FileStatus::SUCCESS.to_s
    assert_instance_of FileStatus, FileStatus::ERROR
    assert_equal 'error', FileStatus::ERROR.to_s
    assert_instance_of FileStatus, FileStatus::CANCELLED
    assert_equal 'cancelled', FileStatus::CANCELLED.to_s
  end

  test 'should raise error when invalid status constant is used' do
    assert_raises(NameError, 'uninitialized constant FileStatus::INVALID_STATUS') do
      FileStatus::INVALID_STATUS
    end
  end

  test 'retryable_statuses returns cancellable and error statuses' do
    assert_includes FileStatus.retryable_statuses, FileStatus::CANCELLED
    assert_includes FileStatus.retryable_statuses, FileStatus::ERROR
    refute_includes FileStatus.retryable_statuses, FileStatus::SUCCESS
    refute_includes FileStatus.retryable_statuses, FileStatus::PENDING
  end
end
