# frozen_string_literal: true
require 'test_helper'

class DetachedProcessControllerTest < ActionDispatch::IntegrationTest

  test 'status responds with success and launches script' do
    Command::CommandClient.any_instance.stubs(:request).returns(
      Command::Response.ok(body: { pending: 0, progress: 0 })
    )
    ScriptLauncher.any_instance.expects(:launch_script).once

    get detached_process_status_path

    assert_response :success
  end
end
