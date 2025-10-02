# frozen_string_literal: true
require 'singleton'

module Command
  class CommandRegistry
    include Singleton
    include LoggingCommon

    def initialize
      @registry = Hash.new { |h, k| h[k] = [] } # command => [services]
    end

    def register(command, service)
      raise ArgumentError, "Service must implement CommandHandler interface" unless service.is_a?(CommandHandler)
      log_info('Registering command',{command:command, service: service.class.name})
      @registry[command.to_s] << service
    end

    def dispatch(request)
      log_info('Dispatching command',{command: request.command, body: request.body})

      handlers = @registry[request.command]
      handlers.each do |handler|
        begin
          result = handler.handle_command(request)
          return Command::Response.ok(body: result, handler: handler) if result
        rescue => e
          log_error('Error while executing handler',{request: request.inspect, handler: handler.class.name}, e)
          return Command::Response.error(message: e.message, handler: handler)
        end
      end

      body = {
        message: 'No handler executed for this command',
        handlers: handlers.map{|h| h.class.name}
      }
      return Command::Response.new(status: 400, body: body)
    end

    def reset!
      @registry.clear
    end
  end
end
