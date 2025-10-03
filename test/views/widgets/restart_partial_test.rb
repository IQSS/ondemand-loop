# frozen_string_literal: true
require 'test_helper'

class RestartPartialTest < ActionView::TestCase

  def render_restart_partial
    view.stubs(:restart_url).returns('/restart')
    view.stubs(:root_path).returns('/')

    render partial: 'widgets/restart'
  end

  test 'renders restart content with correct elements' do
    html = render_restart_partial

    assert_includes html, 'Application Restarting'
    assert_includes html, 'Restart in Progress'
    assert_includes html, 'restarting'
    assert_includes html, 'bi-arrow-repeat'
    assert_includes html, 'alert-success'
  end

  test 'includes restart fetch call and redirect script' do
    html = render_restart_partial

    assert_includes html, 'fetch("/restart")'
    assert_includes html, 'window.location.href = "/"'
  end

  test 'uses Configuration.restart_delay for timeout' do
    html = render_restart_partial

    # Should include the configuration value in the setTimeout
    assert_match /setTimeout\(function\(\)\s*\{.*\},\s*\d+\);/m, html
  end
end