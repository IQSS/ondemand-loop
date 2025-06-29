# frozen_string_literal: true
require 'test_helper'

class DateTimeCommonTest < ActiveSupport::TestCase
  include DateTimeCommon

  test 'now should return current time formatted as ISO8601 without timezone' do
    now_time = Time.now
    result = now
    parsed_time = Time.parse(result)
    assert_in_delta now_time.to_i, parsed_time.to_i, 2
  end

  test 'elapsed should calculate seconds between two times' do
    from = Time.now - 3600 # 1 hour ago
    to = Time.now
    assert_in_delta 3600, elapsed(from, to), 2
  end

  test 'elapsed should default to now if to is not provided' do
    from = Time.now - 1800 # 30 minutes ago
    assert_in_delta 1800, elapsed(from), 2
  end

  test 'elapsed_string should format elapsed time as HH:MM:SS' do
    from = Time.now - 3661 # 1 hour, 1 minute, 1 second ago
    result = elapsed_string(from, Time.now)
    assert_equal '01:01:01', result
  end

  test 'get_date should return date part as string' do
    datetime = Time.new(2024, 4, 27, 15, 30, 45)
    assert_equal '2024-04-27', get_date(datetime)
  end

  test 'get_time should return time part as string' do
    datetime = Time.new(2024, 4, 27, 15, 30, 45)
    assert_equal '15:30:45', get_time(datetime)
  end

  test 'get_date should return nil if input is blank' do
    assert_nil get_date(nil)
    assert_nil get_date('')
  end

  test 'get_time should return nil if input is blank' do
    assert_nil get_time(nil)
    assert_nil get_time('')
  end

  test 'to_time should parse string into Time object' do
    time_string = '2024-04-27T15:30:45'
    parsed = to_time(time_string)
    assert_instance_of Time, parsed
    assert_equal 2024, parsed.year
    assert_equal 4, parsed.month
    assert_equal 27, parsed.day
  end

  test 'to_time should parse integer into Time object' do
    timestamp = 1_710_000_000
    parsed = to_time(timestamp)
    assert_instance_of Time, parsed
    assert_equal timestamp, parsed.to_i
  end

  test 'to_time should convert DateTime into Time' do
    datetime = DateTime.now
    parsed = to_time(datetime)
    assert_instance_of Time, parsed
    assert_in_delta datetime.to_time.to_i, parsed.to_i, 1
  end

  test 'to_time should accept Time object' do
    time = Time.now
    parsed = to_time(time)
    assert_equal time, parsed
  end

  test 'to_time should return nil for blank input' do
    assert_nil to_time(nil)
    assert_nil to_time('')
  end

  test 'to_time should raise error for unsupported type' do
    assert_raises(ArgumentError) do
      to_time(['invalid'])
    end
  end
end
