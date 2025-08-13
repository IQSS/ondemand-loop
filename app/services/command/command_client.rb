# frozen_string_literal: true
require 'timeout'

module Command
  class CommandClient
    include LoggingCommon

    class TimeoutError < StandardError; end
    class CommandError < StandardError; end

    def initialize(socket_path:)
      @socket_path = socket_path
    end

    def request(request, timeout: 1)
      socket = nil
      unless File.exist?(@socket_path)
        log_error('Socket file not found', { socket: @socket_path })
        return Response.error(status: 521, message: 'Socket file not found')
      end

      log_info('Sending command', { socket: @socket_path, command: request.command })

      Timeout.timeout(timeout) do
        begin
          socket = UNIXSocket.new(@socket_path)
          socket.puts(request.to_json)
          raw_response = socket.gets

          if raw_response.nil?
            log_error('No response from server', { command: request.command })
            return Response.error(message: "No response from server for request=#{request.inspect}")
          end

          response = Command::Response.from_json(raw_response.strip)
          log_info('Command response', { status: response.status })
          response
        rescue => e
          log_error('Error processing request', { request: request.inspect }, e)
          raise CommandError, "Error processing request for request=#{request.inspect} error=#{e.message}"
        ensure
          socket&.close
        end
      end
    rescue Timeout::Error
      log_error('Request timed out', { command: request.command })
      raise TimeoutError, "Request timed out for request=#{request.inspect}"
    end
  end
end
