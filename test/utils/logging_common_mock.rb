module LoggingCommonMock
  def log_error(message, context = {}, exception = nil)
    @logged_messages ||= []
    @logged_messages << { type: 'error', message: message, context: context, exception: exception }
  end

  def logged_messages
    @logged_messages || []
  end
end