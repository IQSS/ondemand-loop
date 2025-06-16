# frozen_string_literal: true

# Utility module for handling common date and time operations.
# This module provides methods to extract the date and time from
# a given input, whether it's a String, DateTime, or Time object.
#
module DateTimeCommon

  def now
    to_string(Time.now)
  end

  def to_string(date)
    return nil if date.nil?

    date.strftime('%Y-%m-%dT%H:%M:%S')
  end

  def elapsed(from, to = nil)
    to_time = to_time(to || Time.now)
    from_time = to_time(from)
    (to_time - from_time).to_i
  end

  def elapsed_string(from, to = nil)
    format_elapsed(elapsed(from, to))
  end

  def format_elapsed(total_seconds)
    Time.at(total_seconds).utc.strftime('%H:%M:%S')
  end

  def get_date(date_time)
    return nil if date_time.blank?
    parsed_date_time = to_time(date_time)

    parsed_date_time.strftime('%Y-%m-%d')
  end

  def get_time(date_time)
    return nil if date_time.blank?
    parsed_date_time = to_time(date_time)

    parsed_date_time.strftime('%H:%M:%S')
  end

  # A helper method to parse a String, DateTime, or Time object to a Time object
  def to_time(value)
    return nil if value.blank?

    case value
    when String
      Time.parse(value)
    when Integer
      Time.at(value)
    when DateTime
      value.to_time
    when Time
      value
    else
      raise ArgumentError, 'Unsupported time format.'
    end
  end

  module_function :now, :to_string, :elapsed, :elapsed_string, :format_elapsed, :to_time
end
