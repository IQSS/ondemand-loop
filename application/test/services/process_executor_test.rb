# frozen_string_literal: true

require 'test_helper'

class ProcessExecutorTest < ActiveSupport::TestCase
  test 'start should run service in a new thread and call start on service' do
    mock_service = mock('MockService')
    mock_service.expects(:start).once
    mock_service.expects(:shutdown).never

    executor = ProcessExecutor.new(mock_service)
    thread = executor.start
    assert_instance_of Thread, thread
    thread.join
  end

  test 'shutdown should call shutdown on service' do
    mock_service = mock('MockService')
    mock_service.expects(:shutdown).once

    executor = ProcessExecutor.new(mock_service)
    executor.shutdown
  end
end
