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
      return Response.error(status: 521, message: 'Socket file not found') unless File.exist?(@socket_path)

      Timeout.timeout(timeout) do
        begin
          socket = UNIXSocket.new(@socket_path)
          socket.puts(request.to_json)
          raw_response = socket.gets

          if raw_response.nil?
            return Response.error(message: "No response from server for request=#{request.inspect}")
          end

          Command::Response.from_json(raw_response.strip)
        rescue => e
          log_error('Error processing request', {request: request.inspect}, e)
          raise CommandError, "Error processing request for request=#{request.inspect} error=#{e.message}"
        ensure
          socket&.close
        end
      end
    rescue Timeout::Error
      raise TimeoutError, "Request timed out for request=#{request.inspect}"
    end
  end
end
