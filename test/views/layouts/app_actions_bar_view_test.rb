# frozen_string_literal: true

require 'test_helper'

class AppActionsBarViewTest < ActionView::TestCase
  setup do
    I18n.backend.store_translations(:en, project_selection: {
      selected_project_label: 'Selected project',
      button_open_project_title: 'Open selected project details page',
      button_open_project_label: 'Open selected project'
    })
    view.stubs(:select_project_list).returns([])
  end
  test 'defaults url to repo_resolver_path' do
    html = render partial: 'layouts/app_actions_bar', locals: { }
    assert_includes html, "action=\"#{repo_resolver_path}\""
  end

  test 'allows overriding url' do
    custom_url = '/custom/path'
    html = render partial: 'layouts/app_actions_bar', locals: { url: custom_url }
    assert_includes html, "action=\"#{custom_url}\""
  end

  test 'includes redirect_back field when on explore page' do
    view.stubs(:on_explore?).returns(true)
    html = render partial: 'layouts/app_actions_bar', locals: { show_images: false }
    assert_includes html, "type=\"hidden\" name=\"redirect_back\""
  end

  test 'omits redirect_back field when not on explore page' do
    view.stubs(:on_explore?).returns(false)
    html = render partial: 'layouts/app_actions_bar', locals: { show_images: false }
    refute_includes html, "name=\"redirect_back\""
  end
end
