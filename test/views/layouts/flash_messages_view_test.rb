# frozen_string_literal: true

require 'test_helper'

class FlashMessagesViewTest < ActionView::TestCase
  test 'renders only allowed flash keys' do
    flash[:notice] = 'hello'
    flash[:foo] = 'bar'

    html = render partial: 'layouts/flash_messages'
    assert_includes html, 'hello'
    refute_includes html, 'bar'
  end
end
