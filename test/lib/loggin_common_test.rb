# frozen_string_literal: true
require 'test_helper'

class LoggingCommonTest < ActiveSupport::TestCase
  include LoggingCommon

  def setup
    @logger = mock
    Rails.stubs(:logger).returns(@logger)
  end

  test 'log_info should call Rails.logger.info with formatted message' do
    @logger.expects(:info).with { |message|
      assert_match(/\[INFO\]/, message)
      assert_match(/Test message/, message)
      assert_match(/key=value/, message)
      true
    }

    log_info('Test message', { key: 'value' })
  end

  test 'log_error should call Rails.logger.error with formatted message' do
    @logger.expects(:error).with { |message|
      assert_match(/\[ERROR\]/, message)
      assert_match(/Error occurred/, message)
      assert_match(/error_code=123/, message)
      refute_match(/\[STACK\]/, message)
      true
    }

    log_error('Error occurred', { error_code: 123 })
  end

  test 'log_error should include exception stack trace if exception provided' do
    exception = StandardError.new('Something went wrong')
    exception.set_backtrace([
                              'line 1', 'line 2', 'line 3', 'line 4', 'line 5', 'line 6'
                            ])

    @logger.expects(:error).with { |message|
      assert_match(/\[ERROR\]/, message)
      assert_match(/Something went wrong/, message)
      assert_match(/\[STACK\] line 1/, message)
      assert_match(/\[STACK\] line 5/, message)
      refute_match(/\[STACK\] line 6/, message) # only first 5 lines
      true
    }

    log_error('Exception occurred', { error: 'critical' }, exception)
  end

  test 'format_log should format log message correctly' do
    formatted = LoggingCommon.send(:format_log, 'DEBUG', 'my_class', 'Testing format', {foo: 'bar', baz: 'qux'})

    assert_match(/\[DEBUG\]/, formatted)
    assert_match(/(\d+)/, formatted)
    assert_match(/my_class/, formatted)
    assert_match(/Testing format/, formatted)
    assert_match(/foo=bar/, formatted)
    assert_match(/baz=qux/, formatted)
    assert_match(/\d{4}-\d{2}-\d{2}/, formatted) # date part
  end

end
