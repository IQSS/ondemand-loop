# frozen_string_literal: true
require 'test_helper'

class ResetServiceTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @lock_file = File.join(@tmp_dir, 'lock_file')
    @socket_file = File.join(@tmp_dir, 'command.server.sock')

    File.write(@lock_file, 'lock')
    File.write(@socket_file, 'socket')

    Configuration.stubs(:metadata_root).returns(@tmp_dir)
    Configuration.stubs(:detached_process_lock_file).returns(@lock_file)
    Configuration.stubs(:command_server_socket_file).returns(@socket_file)

    FileUtils.mkdir_p(@tmp_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir) if Dir.exist?(@tmp_dir)
  end

  test 'reset deletes metadata directory and files' do
    test_file = File.join(@tmp_dir, 'some_file')
    File.write(test_file, 'data')

    assert Dir.exist?(@tmp_dir)
    assert File.exist?(@lock_file)
    assert File.exist?(@socket_file)

    ResetService.new.reset

    refute Dir.exist?(@tmp_dir)
    refute File.exist?(@lock_file)
    refute File.exist?(@socket_file)
  end

  test 'logs error when deletion fails' do
    reset_service = ResetService.new
    reset_service.extend(LoggingCommonMock)

    FileUtils.stubs(:rm_rf).raises(StandardError, 'boom')

    assert_raises(StandardError) { reset_service.reset }
    FileUtils.unstub(:rm_rf)

    assert Dir.exist?(@tmp_dir)
    assert_equal 1, reset_service.logged_messages.size
    assert_match 'Failed to reset application state', reset_service.logged_messages.first[:message]
  end
end
