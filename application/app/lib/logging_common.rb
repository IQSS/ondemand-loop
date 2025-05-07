# frozen_string_literal: true
module LoggingCommon
  def log_info(message, data = {})
    Rails.logger.info(LoggingCommon.format_log("INFO", self.class.name, message, data))
  end

  def log_error(message, data = {}, exception = nil)
    log_message = LoggingCommon.format_log("ERROR", self.class.name, message, data)

    if exception
      # First 5 lines as a stack trace
      log_message += "\n[STACK] " + exception.message
      log_message += "\n[STACK] " + exception.backtrace&.first(5)&.join("\n[STACK] ")
    end

    Rails.logger.error(log_message)
  end

  module_function :log_info, :log_error

  private

  def self.format_log(level, class_name, message, data)
    data_string = data.to_h.map { |key, value| "#{key}=#{value}" }.join(" ")
    "[#{level}](#{Thread.current.object_id}) #{class_name} #{Time.current} - #{message} #{data_string}"
  end
end
