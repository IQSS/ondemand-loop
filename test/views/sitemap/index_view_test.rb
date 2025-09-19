# frozen_string_literal: true

require 'test_helper'

class SitemapIndexViewTest < ActionView::TestCase
  include ApplicationHelper

  def setup
    # Mock I18n translations
    I18n.stubs(:t).with('.page_title').returns('Sitemap')
    I18n.stubs(:t).with('.breadcrumbs_text').returns('Sitemap')
    
    # Set up test navigation structure with proper alignment
    @test_navigation = [
      Nav::MainItem.new(
        id: 'nav-projects',
        label: 'Projects',
        url: '/projects',
        position: 1,
        alignment: 'left'
      ),
      Nav::MainItem.new(
        id: 'repositories',
        label: 'Repositories',
        items: [
          { id: 'nav-dataverse', label: 'Dataverse', url: '/dataverse', position: 1 },
          { id: 'nav-zenodo', label: 'Zenodo', url: '/zenodo', position: 2 },
          { id: 'separator', label: '---', position: 3 },
          { id: 'nav-settings', label: 'Settings', url: '/settings', position: 4 }
        ],
        position: 2,
        alignment: 'left'
      ),
      Nav::MainItem.new(
        id: 'help',
        label: 'Help',
        items: [
          { id: 'nav-guide', label: 'Guide', url: '/guide', new_tab: true, position: 1 },
          { id: 'nav-reset', label: 'Reset', partial: 'reset_button', position: 2 }
        ],
        position: 3,
        alignment: 'right'
      )
    ]
    
    # Set @navigation instance variable that the template expects
    @navigation = @test_navigation
  end

  test 'renders sitemap partial for left-aligned navigation' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: @navigation.select(&:lhs?) }

    assert_includes html, 'Projects'
    assert_includes html, 'Repositories'
    assert_includes html, 'href="/projects"'
  end

  test 'renders sitemap partial for right-aligned navigation' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: @navigation.select(&:rhs?) }

    assert_includes html, 'Help'
  end

  test 'renders dropdown menu items correctly' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: @navigation.select(&:lhs?) }

    assert_includes html, 'Dataverse'
    assert_includes html, 'Zenodo'
    assert_includes html, 'Settings'
    assert_includes html, 'href="/dataverse"'
    assert_includes html, 'href="/zenodo"'
    assert_includes html, 'href="/settings"'
  end

  test 'excludes separator items from sitemap' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: @navigation.select(&:lhs?) }

    # Should not include separator dashes due to next if menu_item.divider?
    assert_not_includes html, '---'
  end

  test 'handles items without URLs using fallback' do
    # Create an item without URL
    no_url_item = Nav::MainItem.new(
      id: 'no-url',
      label: 'No URL Item',
      alignment: 'left'
    )
    
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: [no_url_item] }

    assert_includes html, 'href="#"'
    assert_includes html, 'No URL Item'
  end

  test 'renders navigation items with proper list structure' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: @navigation.select(&:lhs?) }

    # Check for proper HTML structure
    assert_includes html, '<li>'
    assert_includes html, '</li>'
    assert_includes html, '<ul>'
    assert_includes html, '</ul>'
  end

  test 'navigation filtering works correctly' do
    # Test that we can filter navigation items by alignment
    left_items = @navigation.select(&:lhs?)
    right_items = @navigation.select(&:rhs?)
    
    # Both should return arrays that can be rendered
    assert_not_nil left_items
    assert_not_nil right_items
    
    # Should have the expected items
    assert_equal 2, left_items.size
    assert_equal 1, right_items.size
    
    # Check specific items
    assert_equal ['nav-projects', 'repositories'], left_items.map(&:id)
    assert_equal ['help'], right_items.map(&:id)
  end


  test 'partial handles empty navigation gracefully' do
    html = render partial: 'sitemap/navigation_items', locals: { nav_items: [] }
    
    # Should not crash and return empty content
    assert_not_nil html
  end
end