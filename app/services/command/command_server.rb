# frozen_string_literal: true

module Command
  class CommandServer
    include LoggingCommon

    def initialize(socket_path:)
      @socket_path = socket_path
      @server = nil
      @server_thread = nil

      start_socket
    end

    def start
      @server_thread = Thread.new do
        begin
          log_info('Server start', {socket: @socket_path})
          loop do
            client = @server.accept
            handle_request(client)
          end
        rescue => e
          log_error('Server socket error', {socket: @socket_path}, e) unless @shutdown
        end
      end
    end

    def restart
      log_info('Restarting server...')
      shutdown
      start_socket
      start
    end

    def shutdown
      log_info('Shutting down server...')
      @shutdown = true
      @server&.close # Triggers accept to raise in the server thread
      @server_thread&.join
      FileUtils.rm_f(@socket_path)
      log_info('Shutdown completed')
    end

    private

    def start_socket
      FileUtils.rm_f(@socket_path)
      @server = UNIXServer.new(@socket_path)
      log_info('UNIXServer created')
    end

    def handle_request(client)
      raw = client.gets
      return unless raw

      begin
        request = Command::Request.from_json(raw.strip)
        result = Command::CommandRegistry.instance.dispatch(request)

        client.puts(result.to_json)
      rescue => e
        log_error('Error processing request', {request: raw}, e)
        error = Command::Response.error(message: e.message)
        client.puts(error.to_json)
      ensure
        client.close
      end
    end
  end
end
