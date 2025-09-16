# frozen_string_literal: true

require 'test_helper'

class NavViewTest < ActionView::TestCase
  include ApplicationHelper

  def setup
    # Mock the navigation method to return test navigation items
    @test_navigation = [
      Nav::MainItem.new(
        id: 'nav-projects',
        label: 'Projects',
        url: '/projects',
        position: 1,
        alignment: 'left'
      ),
      Nav::MainItem.new(
        id: 'nav-downloads',
        label: 'Downloads',
        url: '/downloads',
        position: 2,
        alignment: 'left',
        icon: 'bs://bi-download'
      ),
      Nav::MainItem.new(
        id: 'repositories-dropdown',
        label: 'Repositories',
        items: [
          { id: 'nav-dataverse', label: 'Dataverse', url: '/dataverse', icon: 'connector://dataverse', position: 1 },
          { id: 'nav-zenodo', label: 'Zenodo', url: '/zenodo', icon: 'connector://zenodo', position: 2 },
          { id: 'separator', label: '---', position: 3 },
          { id: 'nav-settings', label: 'Settings', url: '/settings', icon: 'bs://bi-gear', position: 4 }
        ],
        position: 3,
        alignment: 'left'
      ),
      Nav::MainItem.new(
        id: 'nav-help',
        label: 'Help',
        items: [
          { id: 'nav-guide', label: 'Guide', url: '/guide', new_tab: true, icon: 'bs://bi-book', position: 1 },
          { id: 'nav-reset', label: 'Reset', partial: 'reset_button', position: 2 }
        ],
        position: 1,
        alignment: 'right'
      ),
      Nav::MainItem.new(
        id: 'nav-label-only',
        label: 'Label Only',
        position: 2,
        alignment: 'right'
      )
    ]
  end

  test 'renders main nav structure with navbar classes' do
    html = render partial: 'layouts/nav/nav', locals: { navigation: @test_navigation }

    assert_includes html, '<nav class="navbar navbar-expand-lg shadow-sm bg-dark"'
    assert_includes html, 'data-bs-theme="dark"'
    assert_includes html, 'aria-label="Main navigation"'
    assert_includes html, 'class="container-fluid"'
  end

  test 'renders mobile toggle button' do
    html = render partial: 'layouts/nav/nav', locals: { navigation: @test_navigation }

    assert_includes html, 'class="navbar-toggler"'
    assert_includes html, 'data-bs-toggle="collapse"'
    assert_includes html, 'data-bs-target="#navbar-content"'
    assert_includes html, 'aria-label="Toggle navigation"'
  end

  test 'renders left-aligned navigation items' do
    html = render partial: 'layouts/nav/nav', locals: { navigation: @test_navigation }

    assert_includes html, 'class="navbar-nav me-auto mb-2 mb-lg-0"'
    assert_includes html, 'Projects'
    assert_includes html, 'Downloads'
    assert_includes html, 'Repositories'
  end

  test 'renders right-aligned navigation items' do
    html = render partial: 'layouts/nav/nav', locals: { navigation: @test_navigation }

    assert_includes html, 'class="navbar-nav ms-auto"'
    assert_includes html, 'Help'
    assert_includes html, 'Label Only'
  end

  test 'renders process status widget' do
    html = render partial: 'layouts/nav/nav', locals: { navigation: @test_navigation }

    assert_includes html, 'id="process-status"'
    assert_includes html, 'data-controller="lazy-loader"'
    assert_includes html, 'data-lazy-loader-url-value="/detached_process/status"'
    assert_includes html, 'aria-live="polite"'
  end

  test 'nav_link partial renders basic link item' do
    nav_item = Nav::MainItem.new(
      id: 'test-link',
      label: 'Test Link',
      url: '/test',
      position: 1
    )

    html = render partial: 'layouts/nav/nav_link', locals: { nav_item: nav_item }

    assert_includes html, '<li class="nav-item">'
    assert_includes html, 'href="/test"'
    assert_includes html, 'id="test-link"'
    assert_includes html, 'Test Link'
    assert_includes html, 'class="nav-link d-flex align-items-center gap-2"'
  end

  test 'nav_link partial renders link with icon' do
    nav_item = Nav::MainItem.new(
      id: 'test-link-icon',
      label: 'Test Link',
      url: '/test',
      icon: 'bs://bi-house'
    )

    html = render partial: 'layouts/nav/nav_link', locals: { nav_item: nav_item }

    # The actual render_icon helper preserves the original Bootstrap icon class
    assert_includes html, 'bi-house'
    assert_includes html, 'main-item-icon'
    assert_includes html, 'Test Link'
  end

  test 'nav_link partial renders link with new_tab attributes' do
    nav_item = Nav::MainItem.new(
      id: 'external-link',
      label: 'External Link',
      url: 'https://example.com',
      new_tab: true
    )

    html = render partial: 'layouts/nav/nav_link', locals: { nav_item: nav_item }

    assert_includes html, 'target="_blank"'
    assert_includes html, 'rel="noopener"'
  end

  test 'nav_menu partial renders dropdown structure' do
    nav_item = Nav::MainItem.new(
      id: 'test',
      label: 'Test Dropdown',
      items: [
        { id: 'sub1', label: 'Sub Item 1', url: '/sub1' }
      ],
      alignment: 'left'
    )

    html = render partial: 'layouts/nav/nav_menu', locals: { nav_item: nav_item }

    assert_includes html, '<li class="nav-item dropdown">'
    assert_includes html, 'class="nav-link dropdown-toggle"'
    assert_includes html, 'id="test-dropdown"'
    assert_includes html, 'data-bs-toggle="dropdown"'
    assert_includes html, 'aria-expanded="false"'
    assert_includes html, 'aria-haspopup="true"'
    assert_includes html, 'aria-controls="test-menu"'
    assert_includes html, 'Test Dropdown'
  end

  test 'nav_menu partial renders dropdown menu items' do
    nav_item = Nav::MainItem.new(
      id: 'test',
      label: 'Test Dropdown',
      items: [
        { id: 'sub1', label: 'Sub Item 1', url: '/sub1' },
        { id: 'sub2', label: 'Sub Item 2', url: '/sub2' }
      ]
    )

    html = render partial: 'layouts/nav/nav_menu', locals: { nav_item: nav_item }

    assert_includes html, '<ul class="dropdown-menu"'
    assert_includes html, 'id="test-menu"'
    assert_includes html, 'Sub Item 1'
    assert_includes html, 'Sub Item 2'
  end

  test 'nav_menu partial renders right-aligned dropdown menu' do
    nav_item = Nav::MainItem.new(
      id: 'right',
      label: 'Right Dropdown',
      items: [{ id: 'sub1', label: 'Sub Item', url: '/sub1' }],
      alignment: 'right'
    )

    html = render partial: 'layouts/nav/nav_menu', locals: { nav_item: nav_item }

    assert_includes html, 'class="dropdown-menu dropdown-menu-end"'
  end

  test 'nav_label partial renders span element' do
    nav_item = Nav::MainItem.new(
      id: 'test-label',
      label: 'Test Label'
    )

    html = render partial: 'layouts/nav/nav_label', locals: { nav_item: nav_item }

    assert_includes html, '<li class="nav-item">'
    assert_includes html, '<span class="nav-link"'
    assert_includes html, 'id="test-label"'
    assert_includes html, 'Test Label'
  end

  test 'nav_label partial renders with icon' do
    nav_item = Nav::MainItem.new(
      id: 'label-with-icon',
      label: 'Label with Icon',
      icon: 'bs://bi-info-circle'
    )

    html = render partial: 'layouts/nav/nav_label', locals: { nav_item: nav_item }

    assert_includes html, 'bi-info-circle'
    assert_includes html, 'Label with Icon'
  end

  test 'nav_menu_link partial renders dropdown link' do
    menu_item = Nav::MenuItem.new(
      id: 'dropdown-link',
      label: 'Dropdown Link',
      url: '/dropdown-link'
    )

    html = render partial: 'layouts/nav/nav_menu_link', locals: { nav_item: menu_item }

    assert_includes html, '<li>'
    assert_includes html, 'class="dropdown-item d-flex align-items-center gap-2"'
    assert_includes html, 'href="/dropdown-link"'
    assert_includes html, 'id="dropdown-link"'
    assert_includes html, 'Dropdown Link'
  end

  test 'nav_menu_link partial renders with icon' do
    menu_item = Nav::MenuItem.new(
      id: 'dropdown-link-icon',
      label: 'Dropdown Link',
      url: '/dropdown-link',
      icon: 'connector://dataverse'
    )

    html = render partial: 'layouts/nav/nav_menu_link', locals: { nav_item: menu_item }

    assert_includes html, 'class="icon-wrapper bg-white text-dark rounded d-inline-flex align-items-center justify-content-center p-1"'
    # The real helper renders an image tag with asset pipeline path
    assert_includes html, 'title="dataverse"'
    assert_includes html, 'alt="dataverse"'
  end

  test 'nav_menu_link partial renders with new_tab attributes' do
    menu_item = Nav::MenuItem.new(
      id: 'external-dropdown',
      label: 'External Dropdown',
      url: 'https://example.com',
      new_tab: true
    )

    html = render partial: 'layouts/nav/nav_menu_link', locals: { nav_item: menu_item }

    assert_includes html, 'target="_blank"'
    assert_includes html, 'rel="noopener"'
  end

  test 'nav_menu_link partial renders custom partial when specified' do
    menu_item = Nav::MenuItem.new(
      id: 'custom-partial-item',
      label: 'Custom Item',
      partial: 'reset_button'
    )

    html = render partial: 'layouts/nav/nav_menu_link', locals: { nav_item: menu_item }

    # The actual reset_button partial will render - check for its key elements
    assert_includes html, 'Custom Item'
    # The reset button partial includes a form and button elements
    assert_includes html, '<button'
    assert_includes html, 'data-controller="utils--link-confirmation"'
  end

  test 'nav_menu_label partial renders dropdown header' do
    menu_item = Nav::MenuItem.new(
      id: 'dropdown-header',
      label: 'Section Header'
    )

    html = render partial: 'layouts/nav/nav_menu_label', locals: { nav_item: menu_item }

    assert_includes html, '<li>'
    assert_includes html, '<span class="dropdown-header">'
    assert_includes html, 'Section Header'
  end

  test 'nav_menu_label partial renders with icon' do
    menu_item = Nav::MenuItem.new(
      id: 'header-with-icon',
      label: 'Header with Icon',
      icon: 'bs://bi-folder'
    )

    html = render partial: 'layouts/nav/nav_menu_label', locals: { nav_item: menu_item }

    assert_includes html, 'bi-folder'
    assert_includes html, 'Header with Icon'
  end

  test 'nav_menu_divider partial renders separator' do
    menu_item = Nav::MenuItem.new(
      id: 'separator',
      label: '---'
    )

    html = render partial: 'layouts/nav/nav_menu_divider', locals: { nav_item: menu_item }

    assert_includes html, '<li><hr class="dropdown-divider"'
    assert_includes html, 'role="separator"'
  end

  test 'renders complete navigation with NavDefaults items' do
    # Use actual NavDefaults to test real navigation structure
    nav_defaults_items = Nav::NavDefaults.navigation_items

    html = render partial: 'layouts/nav/nav', locals: { navigation: nav_defaults_items }

    # Check for expected navigation items from NavDefaults
    assert_includes html, I18n.t('layouts.nav.navigation.link_projects_text')
    assert_includes html, I18n.t('layouts.nav.navigation.link_downloads_text')
    assert_includes html, I18n.t('layouts.nav.navigation.link_uploads_text')
    assert_includes html, I18n.t('layouts.nav.navigation.link_repositories_text')
    assert_includes html, I18n.t('layouts.nav.navigation.link_help_text')

    # Check for dropdown structure
    assert_includes html, 'data-bs-toggle="dropdown"'
    assert_includes html, 'class="dropdown-menu'

    # Check for dataverse and zenodo links
    assert_includes html, I18n.t('layouts.nav.navigation.link_dataverse_text')
    assert_includes html, I18n.t('layouts.nav.navigation.link_zenodo_text')

    # Check for right-aligned items
    assert_includes html, 'Open OnDemand'
  end

  test 'partial selection based on nav_item type works correctly' do
    link_item = Nav::MainItem.new(id: 'link', url: '/link', label: 'Link')
    menu_item = Nav::MainItem.new(id: 'menu', items: [{ id: 'sub', label: 'Sub' }], label: 'Menu')
    label_item = Nav::MainItem.new(id: 'label', label: 'Label')

    assert_equal 'nav_link', link_item.partial_name
    assert_equal 'nav_menu', menu_item.partial_name
    assert_equal 'nav_label', label_item.partial_name

    # Test that the correct partials get rendered
    link_html = render partial: "layouts/nav/#{link_item.partial_name}", locals: { nav_item: link_item }
    menu_html = render partial: "layouts/nav/#{menu_item.partial_name}", locals: { nav_item: menu_item }
    label_html = render partial: "layouts/nav/#{label_item.partial_name}", locals: { nav_item: label_item }

    assert_includes link_html, 'href="/link"'
    assert_includes menu_html, 'data-bs-toggle="dropdown"'
    assert_includes label_html, '<span class="nav-link"'
  end

  test 'menu item type selection works correctly' do
    link_menu_item = Nav::MenuItem.new(id: 'menu-link', url: '/menu-link', label: 'Menu Link')
    divider_menu_item = Nav::MenuItem.new(id: 'divider', label: '---')
    label_menu_item = Nav::MenuItem.new(id: 'menu-label', label: 'Menu Label')

    assert_equal 'nav_menu_link', link_menu_item.partial_name
    assert_equal 'nav_menu_divider', divider_menu_item.partial_name
    assert_equal 'nav_menu_label', label_menu_item.partial_name

    # Test that the correct menu partials get rendered
    link_html = render partial: "layouts/nav/#{link_menu_item.partial_name}", locals: { nav_item: link_menu_item }
    divider_html = render partial: "layouts/nav/#{divider_menu_item.partial_name}", locals: { nav_item: divider_menu_item }
    label_html = render partial: "layouts/nav/#{label_menu_item.partial_name}", locals: { nav_item: label_menu_item }

    assert_includes link_html, 'class="dropdown-item'
    assert_includes divider_html, 'class="dropdown-divider"'
    assert_includes label_html, 'class="dropdown-header"'
  end
end