# frozen_string_literal: true

# ProcessExecutor: wraps any service that responds to `start` and `shutdown`
class ProcessExecutor
  include LoggingCommon

  attr_reader :name

  def initialize(service)
    @service = service
    @name = service.class.name
  end

  def start
    log_info('Starting service', {name: @name})
    Thread.new do
      @service.start
      log_info('Finished service', {name: @name})
    rescue => e
      log_error('Error executing service', {name: @name}, e)
    end
  end

  def shutdown
    log_info('Shutting down', {name: @name})
    @service.shutdown
  rescue => e
    log_error('Error shutting down service', {name: @name}, e)
  end
end
