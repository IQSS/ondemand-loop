# frozen_string_literal: true

# DetachedServicesManager: orchestrates multiple ProcessExecutors
class DetachedServicesManager
  include LoggingCommon

  def initialize(services, interval: Configuration.detached_controller_interval)
    @interval = interval
    @executor_threads = services.map { |service| ProcessExecutor.new(service) }.to_h { |executor| [executor, nil] }

    @mutex = Mutex.new
    @condition = ConditionVariable.new
    @shutdown = false
  end

  def run
    log_info('ServiceManager started', {executors: @executor_threads.size})

    all_idle = true
    loop do
      @executor_threads.each do |executor, thread|
        if thread_terminated?(thread)
          @executor_threads[executor] = executor.start
        end
      end

      # wait for either the interval or a signal
      @mutex.synchronize {
        break if @shutdown
        @condition.wait(@mutex, @interval)
      }

      all_idle = @executor_threads.values.all? { |t| thread_terminated?(t) }
      if all_idle || @shutdown
        break
      end
    end

    log_info('Shutting down...', {all_idle: all_idle, shutdown: @shutdown, executors: @executor_threads.size})
    @executor_threads.each_key(&:shutdown)
    log_info('Completed', {executors: @executor_threads.size})
  rescue => e
    log_error('Error', {shutdown: @shutdown, executors: @executor_threads.size}, e)
  end

  def shutdown
    log_info('Shutdown requested')
    @mutex.synchronize do
      @shutdown = true
      @condition.broadcast # wake up the loop immediately
    end
  end

  private

  def thread_terminated?(thread)
    thread.nil? || [nil, false].include?(thread.status)
  end
end
