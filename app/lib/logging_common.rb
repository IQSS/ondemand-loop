# frozen_string_literal: true
module LoggingCommon
  def log_info(message, data = {})
    Rails.logger.info(format_log("INFO", message, data))
  end

  def log_error(message, data = {})
    Rails.logger.error(format_log("ERROR", message, data))
  end

  private

  def format_log(level, message, data)
    data_string = data.to_h.map { |key, value| "#{key}=#{value}" }.join(" ")
    "[#{level}] #{self.class.name} #{Time.current} - #{message} #{data_string}"
  end
end
