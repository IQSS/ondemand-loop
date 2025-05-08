# frozen_string_literal: true

# DetachedProcessController: orchestrates multiple ProcessExecutors
class DetachedProcessController
  include LoggingCommon

  def initialize(services, interval: Configuration.detached_controller_interval)
    @interval = interval
    @executor_threads = services.map { |service| ProcessExecutor.new(service) }.to_h { |executor| [executor, nil] }
  end

  def run
    log_info('Process controller started', {executors: @executor_threads.size})

    loop do
      @executor_threads.each do |executor, thread|
        if thread_terminated?(thread)
          log_info('Launching executor', {name: executor.name})
          @executor_threads[executor] = executor.start
        end
      end

      sleep @interval

      all_idle = @executor_threads.values.all? { |t| thread_terminated?(t) }

      if all_idle
        log_info('All executors idle. Shutting down...', {executors: @executor_threads.size})
        @executor_threads.each_key(&:shutdown)
        log_info('Completed', {executors: @executor_threads.size})
        break
      end
    end
  rescue => e
    log_error('Error', {}, e)
  end

  private

  def thread_terminated?(thread)
    thread == nil || [nil, false].include?(thread.status)
  end
end
