# frozen_string_literal: true

require 'test_helper'

class DetachedServicesManagerTest < ActiveSupport::TestCase
  # MockService simulates a service that can be started and shut down
  class MockService
    attr_reader :start_count, :shutdown_count

    def initialize(work_time: 0.1, fail_on_start: false, fail_on_shutdown: false)
      @work_time = work_time
      @fail_on_start = fail_on_start
      @fail_on_shutdown = fail_on_shutdown
      @start_count = 0
      @shutdown_count = 0
    end

    def start
      @start_count += 1
      raise StandardError, 'Start failed' if @fail_on_start

      sleep @work_time
    end

    def shutdown
      @shutdown_count += 1
      raise StandardError, 'Shutdown failed' if @fail_on_shutdown
    end
  end

  test 'starts all services and shuts down when all are idle' do
    service1 = MockService.new(work_time: 0.05)
    service2 = MockService.new(work_time: 0.05)

    manager = DetachedServicesManager.new([service1, service2], interval: 0.5)

    manager.run

    assert_equal 1, service1.start_count
    assert_equal 1, service2.start_count
    assert_equal 1, service1.shutdown_count
    assert_equal 1, service2.shutdown_count
  end

  test 'restarts terminated services before shutdown is requested' do
    fast_service = MockService.new(work_time: 0.05)
    long_service = MockService.new(work_time: 0.3)

    manager = DetachedServicesManager.new([fast_service, long_service], interval: 0.1)

    manager.run

    # Fast service should restart at least once before long service finishes
    assert_operator fast_service.start_count, :>=, 2
    assert_operator long_service.start_count, :>=, 1
    assert_equal 1, fast_service.shutdown_count
    assert_equal 1, long_service.shutdown_count
  end

  test 'shutdown wakes up manager immediately from wait' do
    long_service = MockService.new(work_time: 5.0)

    manager = DetachedServicesManager.new([long_service], interval: 10.0)

    # Run manager in a thread
    manager_thread = Thread.new { manager.run }

    # Give manager time to start and enter wait state
    sleep 0.1

    start_time = Time.now
    manager.shutdown
    manager_thread.join

    elapsed = Time.now - start_time

    # Should shutdown quickly (< 1 second), not wait for 10 second interval
    assert_operator elapsed, :<, 1.0
    assert_equal 1, long_service.shutdown_count
  end

  test 'does not restart services after shutdown is requested' do
    fast_service = MockService.new(work_time: 0.05)

    manager = DetachedServicesManager.new([fast_service], interval: 0.2)

    manager_thread = Thread.new { manager.run }

    # Give fast service time to complete once
    sleep 0.15

    # Request shutdown before it would restart
    manager.shutdown
    manager_thread.join

    # Should only have started once, not restarted
    assert_equal 1, fast_service.start_count
    assert_equal 1, fast_service.shutdown_count
  end

  test 'handles service that fails on start' do
    failing_service = MockService.new(fail_on_start: true)
    good_service = MockService.new(work_time: 0.05)

    manager = DetachedServicesManager.new([failing_service, good_service], interval: 0.5)

    assert_nothing_raised do
      manager.run
    end

    assert_equal 1, failing_service.start_count
    assert_equal 1, good_service.start_count
    assert_equal 1, failing_service.shutdown_count
    assert_equal 1, good_service.shutdown_count
  end

  test 'handles service that fails on shutdown' do
    failing_service = MockService.new(work_time: 0.05, fail_on_shutdown: true)
    good_service = MockService.new(work_time: 0.05)

    manager = DetachedServicesManager.new([failing_service, good_service], interval: 0.5)

    assert_nothing_raised do
      manager.run
    end

    # Both services should complete shutdown attempt despite one failing
    assert_equal 1, failing_service.shutdown_count
    assert_equal 1, good_service.shutdown_count
  end

  test 'handles multiple shutdown calls gracefully' do
    service = MockService.new(work_time: 0.5)

    manager = DetachedServicesManager.new([service], interval: 1.0)

    manager_thread = Thread.new { manager.run }

    sleep 0.1

    # Call shutdown multiple times
    assert_nothing_raised do
      manager.shutdown
      manager.shutdown
      manager.shutdown
    end

    manager_thread.join

    assert_equal 1, service.shutdown_count
  end

  test 'exits cleanly when all services complete and none need restarting' do
    service1 = MockService.new(work_time: 0.05)
    service2 = MockService.new(work_time: 0.05)

    manager = DetachedServicesManager.new([service1, service2], interval: 0.2)

    start_time = Time.now
    manager.run
    elapsed = Time.now - start_time

    # Should exit after one interval check (roughly interval + service time)
    assert_operator elapsed, :<, 0.5
    assert_equal 1, service1.shutdown_count
    assert_equal 1, service2.shutdown_count
  end

  test 'shutdown during service execution stops manager loop' do
    slow_service1 = MockService.new(work_time: 2.0)
    slow_service2 = MockService.new(work_time: 2.0)

    manager = DetachedServicesManager.new([slow_service1, slow_service2], interval: 0.5)

    manager_thread = Thread.new { manager.run }

    sleep 0.1

    start_time = Time.now
    manager.shutdown
    manager_thread.join
    elapsed = Time.now - start_time

    # Should shutdown quickly despite services still running
    assert_operator elapsed, :<, 1.0
    assert_equal 1, slow_service1.shutdown_count
    assert_equal 1, slow_service2.shutdown_count
  end
end
