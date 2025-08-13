# frozen_string_literal: true

require 'test_helper'

module Common
  class FileSorterTest < ActiveSupport::TestCase
    def setup
      @sorter = FileSorter.new
      @project = create_project
      @upload_bundle = create_upload_bundle(@project)
    end

    test 'most_relevant sorts files by status and available date' do
      times = (1..10).map { |i| format('2023-01-%02dT00:00:00', i) }

      in_progress_new = create_download_file(@project)
      in_progress_new.status = FileStatus::DOWNLOADING
      in_progress_new.start_date = times[9]

      in_progress_old = create_upload_file(@project, @upload_bundle)
      in_progress_old.status = FileStatus::UPLOADING
      in_progress_old.start_date = times[8]

      pending_new = create_upload_file(@project, @upload_bundle)
      pending_new.status = FileStatus::PENDING
      pending_new.creation_date = times[7]

      pending_old = create_download_file(@project)
      pending_old.status = FileStatus::PENDING
      pending_old.creation_date = times[6]

      cancelled_new = create_upload_file(@project, @upload_bundle)
      cancelled_new.status = FileStatus::CANCELLED
      cancelled_new.end_date = times[5]

      cancelled_old = create_download_file(@project)
      cancelled_old.status = FileStatus::CANCELLED
      cancelled_old.end_date = times[4]

      error_new = create_download_file(@project)
      error_new.status = FileStatus::ERROR
      error_new.end_date = times[3]

      error_old = create_upload_file(@project, @upload_bundle)
      error_old.status = FileStatus::ERROR
      error_old.end_date = times[2]

      success_new = create_upload_file(@project, @upload_bundle)
      success_new.status = FileStatus::SUCCESS
      success_new.end_date = times[1]

      success_old = create_download_file(@project)
      success_old.status = FileStatus::SUCCESS
      success_old.end_date = times[0]

      expected = [
        in_progress_new,
        in_progress_old,
        pending_new,
        pending_old,
        cancelled_new,
        cancelled_old,
        error_new,
        error_old,
        success_new,
        success_old
      ]

      shuffled = expected.shuffle(random: Random.new(1))
      assert_equal expected, @sorter.most_relevant(shuffled)
    end
  end
end
