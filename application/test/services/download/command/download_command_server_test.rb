# frozen_string_literal: true
require 'test_helper'

class Download::Command::DownloadCommandServerTest < ActiveSupport::TestCase
  def setup
    @tmpdir = Dir.mktmpdir
    @socket_path = File.join(@tmpdir, "command_server.sock")

    @registry = Download::Command::DownloadCommandRegistry.instance
    @registry.reset!

    # Register a default handler for 'test_command'
    handler = Class.new do
      def process(request)
        { echo: request.body.to_h }
      end
    end.new

    @registry.register("test_command", handler)

    @server = Download::Command::DownloadCommandServer.new(socket_path: @socket_path)
    @server.start
    sleep 0.1
  end

  def teardown
    @server.shutdown
    FileUtils.remove_entry(@tmpdir) if File.directory?(@tmpdir)
    @registry.reset!
  end

  test 'Should dispatch request and return response correctly' do
    socket = UNIXSocket.new(@socket_path)
    request = Download::Command::Request.new(command: 'test_command', body: { value: 42 })
    socket.puts(request.to_json)
    response = Download::Command::Response.from_json(socket.gets)
    socket.close

    assert_equal 200, response.status
    assert_equal 42, response.body.echo[:value]
  end

  test 'Should restart the server and respond again after restart' do
    @server.restart
    sleep 0.1

    assert File.socket?(@socket_path), "Socket file should exist after restart"

    socket = UNIXSocket.new(@socket_path)
    request = Download::Command::Request.new(command: 'test_command', body: { value: 99 })
    socket.puts(request.to_json)
    response = Download::Command::Response.from_json(socket.gets)
    socket.close

    assert_equal 200, response.status
    assert_equal 99, response.body.echo[:value]
  end

  test 'Should recover from simulated socket failure via restart' do
    @server.instance_variable_get(:@server)&.close
    FileUtils.rm_f(@socket_path)

    assert_raises(Errno::ENOENT) do
      UNIXSocket.new(@socket_path)
    end

    @server.restart
    sleep 0.1

    socket = UNIXSocket.new(@socket_path)
    request = Download::Command::Request.new(command: 'test_command', body: { message: 'recovered' })
    socket.puts(request.to_json)
    response = Download::Command::Response.from_json(socket.gets)
    socket.close

    assert_equal 200, response.status
    assert_equal 'recovered', response.body.echo[:message]
  end

  test 'Should return error response when handler raises exception' do
    handler = Class.new do
      def process(_payload)
        raise StandardError, "Something bad happened"
      end
    end.new

    @registry.register("failing_command", handler)

    socket = UNIXSocket.new(@socket_path)
    request = Download::Command::Request.new(command: 'failing_command')
    socket.puts(request.to_json)
    response = Download::Command::Response.from_json(socket.gets)
    socket.close

    assert_equal 500, response.status
    assert_match /Something bad happened/, response.body.message
  end

  test 'Should return error response when receiving invalid JSON' do
    socket = UNIXSocket.new(@socket_path)
    socket.puts("this is not json")
    response = Download::Command::Response.from_json(socket.gets)
    socket.close

    assert_equal 500, response.status
    assert_match /unexpected token/i, response.body.message
  end

  test 'shutdown can be called multiple times safely' do
    assert_nothing_raised do
      3.times { @server.shutdown }
    end
  end
end
