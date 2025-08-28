# frozen_string_literal: true
require 'test_helper'

class ResetPartialTest < ActionView::TestCase

  def render_with(method: :post)
    request = ActionDispatch::TestRequest.create
    request.request_method = method.to_s.upcase

    view.stubs(:request).returns(request)
    view.stubs(:restart_url).returns('/restart')
    view.stubs(:root_path).returns('/')

    render partial: 'widgets/reset'
  end

  test 'renders success when request is POST' do
    html = render_with(method: :post)

    assert_includes html, 'Reset Completed'
    assert_includes html, 'successfully reset'
    assert_includes html, 'window.location.href = "/restart"'
    assert_includes html, 'bi-check-circle-fill'
  end

  test 'renders error when request is GET' do
    html = render_with(method: :get)

    assert_includes html, 'Invalid Request'
    assert_includes html, 'only allowed via POST'
    assert_includes html, 'window.location.href = "/"'
    assert_includes html, 'bi-exclamation-octagon-fill'
  end
end
