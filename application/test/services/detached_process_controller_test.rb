# frozen_string_literal: true

require 'test_helper'

class DetachedProcessControllerTest < ActiveSupport::TestCase
  class MockService
    def initialize(work_time: 0.1, shutdown_error: false)
      @work_time = work_time
      @shutdown_error = shutdown_error
    end

    def start
      sleep @work_time
    end

    def shutdown
      raise StandardError, 'Shutdown failed' if @shutdown_error
    end
  end

  test 'controller starts all services and shuts down when all are idle' do
    service1 = MockService.new(work_time: 0.2)
    service2 = MockService.new(work_time: 0.2)

    service1.expects(:shutdown).once
    service2.expects(:shutdown).once

    controller = DetachedProcessController.new([service1, service2], interval: 0.5)

    assert_nothing_raised do
      controller.run
    end
  end

  test 'controller only restarts dead services' do
    fast_service = mock('FastService')
    fast_service.expects(:start).at_least(2)
    fast_service.expects(:shutdown).once

    slow_service = MockService.new(work_time: 1.5)
    slow_service.expects(:shutdown).once

    controller = DetachedProcessController.new([fast_service, slow_service], interval: 0.5)

    assert_nothing_raised do
      controller.run
    end
  end

  test 'controller calls shutdown and exits cleanly even if a service raises an exception' do
    faulty_service = mock('FaultyService')
    faulty_service.expects(:start).raises(StandardError, 'Service failed')
    faulty_service.expects(:shutdown).once

    good_service = MockService.new(work_time: 0.2)
    good_service.expects(:shutdown).once

    controller = DetachedProcessController.new([faulty_service, good_service], interval: 0.5)

    assert_nothing_raised do
      controller.run
    end
  end

  test 'controller calls shutdown on all services even if one raises an exception during shutdown' do
    good_service = MockService.new(work_time: 0.1)
    good_service.expects(:shutdown).once

    faulty_service = MockService.new(work_time: 0.1, shutdown_error: true)
    faulty_service.expects(:shutdown).once.raises(StandardError, 'Shutdown failed')

    controller = DetachedProcessController.new([faulty_service, good_service], interval: 0.2)

    assert_nothing_raised do
      controller.run
    end
  end
end
