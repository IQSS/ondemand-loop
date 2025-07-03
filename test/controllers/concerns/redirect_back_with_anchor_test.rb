# frozen_string_literal: true
require 'test_helper'

class RedirectBackWithAnchorTest < ActionController::TestCase
  class DummyController < ActionController::Base
    include RedirectBackWithAnchor

    def test_action
      redirect_back fallback_location: '/fallback', allow_other_host: true
    end
  end

  tests DummyController

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'test_action' => 'redirect_back_with_anchor_test/dummy#test_action'
    end

    @request.env['action_dispatch.routes'] = @routes
  end

  test 'redirects to referer if present without anchor' do
    @request.env['HTTP_REFERER'] = '/referer_path'
    get :test_action
    assert_redirected_to '/referer_path'
  end

  test 'redirects to fallback if referer is missing' do
    get :test_action
    assert_redirected_to '/fallback'
  end

  test 'redirects to referer with anchor if anchor param is present' do
    @request.env['HTTP_REFERER'] = '/referer_path'
    get :test_action, params: { anchor: 'section' }
    assert_redirected_to '/referer_path#section'
  end

  test 'redirects to fallback with anchor if referer is missing' do
    get :test_action, params: { anchor: 'bottom' }
    assert_redirected_to '/fallback#bottom'
  end

  test 'handles invalid referer URL gracefully' do
    @request.env['HTTP_REFERER'] = '::::invalid:::url'
    get :test_action, params: { anchor: 'bad' }
    assert_redirected_to '::::invalid:::url'
  end
end
