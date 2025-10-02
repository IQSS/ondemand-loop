# frozen_string_literal: true
require 'test_helper'

class Command::CommandClientTest < ActiveSupport::TestCase
  def setup
    @tmpdir = Dir.mktmpdir
    @socket_path = File.join(@tmpdir, 'command.sock')

    @registry = Command::CommandRegistry.instance
    @registry.reset!

    @handler = mock('handler')
    @handler.stubs(:is_a?).with(Command::CommandHandler).returns(true)
    @handler.stubs(:handle_command).returns({ file_status: 'downloading' })
    @registry.register('status', @handler)

    @server = Command::CommandServer.new(socket_path: @socket_path)
    @server.start
    sleep 0.1
  end

  def teardown
    @server.shutdown
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
  end

  test 'Should return error for a command with no handler' do
    client = Command::CommandClient.new(socket_path: @socket_path)
    request = Command::Request.new(command: 'no_handler_registered')
    result = client.request(request)

    assert_equal 400, result.status
    assert_equal 'No handler executed for this command', result.body.message
  end

  test 'Should return response when server responds correctly' do
    client = Command::CommandClient.new(socket_path: @socket_path)
    request = Command::Request.new(command: 'status')
    result = client.request(request)

    assert_equal 200, result.status
    assert_equal'downloading', result.body.file_status
  end

  test 'Should raise TimeoutError when server does not respond in time' do
    slow_handler = Class.new do
      include Command::CommandHandler
      def handle_command(_payload)
        sleep 2
        { result: 'delayed' }
      end
    end.new
    @registry.register('long_task', slow_handler)

    client = Command::CommandClient.new(socket_path: @socket_path)

    assert_raises(Command::CommandClient::TimeoutError) do
      request = Command::Request.new(command: 'long_task')
      client.request(request, timeout: 0.5)
    end
  end

  test 'Should return 521 error response if socket is unavailable' do
    @server.shutdown

    client = Command::CommandClient.new(socket_path: @socket_path)
    request = Command::Request.new(command: 'status')
    result = client.request(request)

    assert_equal 521, result.status
    assert_equal 'Socket file not found. Server not running', result.body.message
  end

  test 'Should raise CommandError if error processing the response' do
    client = Command::CommandClient.new(socket_path: @socket_path)
    JSON.stubs(:parse).raises(StandardError, 'JSON parsing failed')

    error = assert_raises(Command::CommandClient::CommandError) do
      request = Command::Request.new(command: 'status')
      client.request(request)
    end

    assert_match 'Error processing request', error.message
    assert_match 'JSON parsing failed', error.message
  end
end
