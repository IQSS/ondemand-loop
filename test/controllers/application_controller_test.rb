require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  class SettingsStub
    attr_reader :user_settings

    def initialize
      @user_settings = OpenStruct.new
    end

    def update_user_settings(new_values)
      @user_settings = OpenStruct.new(@user_settings.to_h.merge(new_values))
    end
  end

  class DummyController < ApplicationController
    def show
      render plain: Current.settings.user_settings.active_project
    end

    def ajax_action
      render plain: ajax_request?.to_s
    end

    def settings_action
      render plain: Current.settings.class.name
    end
  end

  tests DummyController

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "show" => "application_controller_test/dummy#show"
      get "ajax_action" => "application_controller_test/dummy#ajax_action"
      get "settings_action" => "application_controller_test/dummy#settings_action"
    end
    @request.env["action_dispatch.routes"] = @routes
    @settings_stub = SettingsStub.new
    UserSettings.stubs(:new).returns(@settings_stub)
  end

  def teardown
    Current.settings = nil
  end

  test "load_user_settings sets Current.settings" do
    get :settings_action
    assert_equal SettingsStub.name, @response.body
  end

  test "set_dynamic_user_settings updates active_project" do
    get :show, params: { active_project: "99" }
    assert_equal "99", @settings_stub.user_settings.active_project
  end

  test "ajax_request? returns true when header present" do
    @request.headers["X-Requested-With"] = "XMLHttpRequest"
    get :ajax_action
    assert_equal "true", @response.body
  end

  test "ajax_request? returns false when no header" do
    get :ajax_action
    assert_equal "false", @response.body
  end
end
