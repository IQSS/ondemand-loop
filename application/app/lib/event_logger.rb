# frozen_string_literal: true

module EventLogger
  def record_event(event)
    event.save
  rescue => e
    LoggingCommon.log_error('Cannot record event', { event_class: event.class.name }, e)
    false
  end

  module_function :record_event
end
