# frozen_string_literal: true
require 'test_helper'

class ResetServiceTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    Configuration.stubs(:metadata_root).returns(@tmp_dir)
    FileUtils.mkdir_p(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir) if Dir.exist?(@tmp_dir)
  end

  test 'reset deletes metadata directory' do
    test_file = File.join(@tmp_dir, 'some_file')
    File.write(test_file, 'data')

    assert Dir.exist?(@tmp_dir)
    ResetService.new.reset
    refute Dir.exist?(@tmp_dir)
  end

  test 'logs error when deletion fails' do
    reset_service = ResetService.new
    reset_service.extend(LoggingCommonMock)

    FileUtils.stubs(:rm_rf).raises(StandardError, 'boom')

    assert_raises(StandardError) { reset_service.reset }
    FileUtils.unstub(:rm_rf)

    assert Dir.exist?(@tmp_dir)
    assert_equal 1, reset_service.logged_messages.size
    assert_match 'Failed to delete metadata directory', reset_service.logged_messages.first[:message]
  end
end
