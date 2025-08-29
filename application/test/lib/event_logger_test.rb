# frozen_string_literal: true
require 'test_helper'

class EventLoggerTest < ActiveSupport::TestCase
  include EventLogger

  test 'record_event should save event' do
    event = mock('event')
    event.expects(:save).returns(true)
    assert record_event(event)
  end

  test 'record_event logs error on exception' do
    event = mock('event')
    event.expects(:save).raises(StandardError.new('boom'))
    LoggingCommon.expects(:log_error)
    refute record_event(event)
  end
end
