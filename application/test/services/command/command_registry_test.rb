# frozen_string_literal: true
require 'test_helper'

class Command::CommandRegistryTest < ActiveSupport::TestCase

  def setup
    @registry = Command::CommandRegistry.instance
    @registry.extend(LoggingCommonMock) # override LoggingCommon for test
    @registry.reset!
  end

  test 'registers valid service and dispatch returns first result' do
    handler = Class.new do
      def process(request)
        { foo: request.body.bar }
      end
    end.new

    @registry.register('example', handler)

    request = Command::Request.new(command: 'example', body: {bar: 'baz'})
    result = @registry.dispatch(request)

    assert_equal 200, result.status
    assert_equal handler.class.name.to_s, result.headers[:handler].to_s
    assert_equal 'baz', result.body.foo
  end

  test 'dispatch executes only the first handler that returns non-nil and skips the rest' do
    handler1 = mock('handler1')
    handler2 = mock('handler2')
    handler3 = mock('handler3')

    handler1.expects(:process).returns(nil)
    handler2.expects(:process).returns({ message: 'handled by 2' })
    handler3.expects(:process).never

    @registry.register('first_response', handler1)
    @registry.register('first_response', handler2)
    @registry.register('first_response', handler3)

    request = Command::Request.new(command: 'first_response')
    result = @registry.dispatch(request)

    assert_equal 200, result.status
    assert_equal 'handled by 2', result.body.message
  end


  test 'dispatch handles exception in handler and logs error' do
    handler = mock('handler')
    handler.expects(:process).raises(StandardError, 'handler exploded')

    @registry.register('fail', handler)

    request = Command::Request.new(command: 'fail')
    result = @registry.dispatch(request)
    assert_equal 500, result.status
    assert_equal handler.class.name.to_s, result.headers[:handler]
    assert_match 'handler exploded', result.body.message
    assert_equal 1, @registry.logged_messages.size
    assert_match 'Error while executing handler', @registry.logged_messages.first[:message]
  end

  test 'dispatch returns error if no handlers registered' do
    request = Command::Request.new(command: 'unhandled')
    result = @registry.dispatch(request)
    assert_equal 400, result.status
    assert_nil result.headers[:handler]
    assert_match 'No handler executed', result.body.message
  end

  test 'dispatch returns error if all handlers return nil' do
    handler1 = Class.new { def process(_) = nil }.new
    handler2 = Class.new { def process(_) = nil }.new

    @registry.register('noop', handler1)
    @registry.register('noop', handler2)

    request = Command::Request.new(command: 'noop')
    result = @registry.dispatch(request)
    assert_equal 400, result.status
    assert_nil result.headers[:handler]
    assert_match 'No handler executed', result.body.message
  end

  test 'raises ArgumentError when registering non-processable service' do
    assert_raises(ArgumentError) do
      @registry.register('bad', Object.new) # no #process
    end
  end

  test 'reset! clears all registered handlers' do
    dummy = Class.new { def process(_) = { dummy: true } }.new
    @registry.register('dummy', dummy)

    assert_not_empty @registry.instance_variable_get(:@registry)
    @registry.reset!
    assert_empty @registry.instance_variable_get(:@registry)
  end
end
