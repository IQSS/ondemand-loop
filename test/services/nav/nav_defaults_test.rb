# frozen_string_literal: true

require 'test_helper'

class Nav::NavDefaultsTest < ActiveSupport::TestCase
  test 'navigation_items returns array of Nav::MainItem objects' do
    items = Nav::NavDefaults.navigation_items

    assert_instance_of Array, items
    assert items.all? { |item| item.is_a?(Nav::MainItem) }
    assert items.size > 0
  end

  test 'navigation_items includes expected main navigation items' do
    items = Nav::NavDefaults.navigation_items
    item_ids = items.map(&:id)

    # Check for main navigation items
    assert_includes item_ids, 'nav-projects'
    assert_includes item_ids, 'nav-downloads'
    assert_includes item_ids, 'nav-uploads'
    assert_includes item_ids, 'repositories'
    assert_includes item_ids, 'nav-ood-dashboard'
    assert_includes item_ids, 'help'
  end

  test 'primary navigation items have correct attributes and positioning' do
    items = Nav::NavDefaults.navigation_items
    items_by_id = items.index_by(&:id)

    projects_item = items_by_id['nav-projects']
    assert_equal I18n.t('layouts.nav.navigation.link_projects_text'), projects_item.label
    assert_equal 1, projects_item.position
    assert projects_item.lhs?
    assert projects_item.link?

    downloads_item = items_by_id['nav-downloads']
    assert_equal I18n.t('layouts.nav.navigation.link_downloads_text'), downloads_item.label
    assert_equal 2, downloads_item.position
    assert downloads_item.lhs?
    assert downloads_item.link?

    uploads_item = items_by_id['nav-uploads']
    assert_equal I18n.t('layouts.nav.navigation.link_uploads_text'), uploads_item.label
    assert_equal 3, uploads_item.position
    assert uploads_item.lhs?
    assert uploads_item.link?
  end

  test 'repositories dropdown menu has correct structure' do
    items = Nav::NavDefaults.navigation_items
    repositories_item = items.find { |item| item.id == 'repositories' }

    assert_not_nil repositories_item
    assert_equal I18n.t('layouts.nav.navigation.link_repositories_text'), repositories_item.label
    assert_equal 4, repositories_item.position
    assert repositories_item.lhs?
    assert repositories_item.menu?
    
    # Check menu items
    menu_items = repositories_item.items
    assert_equal 4, menu_items.size
    
    menu_item_ids = menu_items.map(&:id)
    assert_includes menu_item_ids, 'nav-dataverse'
    assert_includes menu_item_ids, 'nav-zenodo'
    assert_includes menu_item_ids, 'repositories-settings-separator'
    assert_includes menu_item_ids, 'nav-repo-settings'
  end

  test 'repositories dropdown menu items have correct attributes' do
    items = Nav::NavDefaults.navigation_items
    repositories_item = items.find { |item| item.id == 'repositories' }
    menu_items = repositories_item.items
    menu_items_by_id = menu_items.index_by(&:id)

    dataverse_item = menu_items_by_id['nav-dataverse']
    assert_equal I18n.t('layouts.nav.navigation.link_dataverse_text'), dataverse_item.label
    assert_equal 'connector://dataverse', dataverse_item.icon
    assert_equal 1, dataverse_item.position
    assert dataverse_item.link?

    zenodo_item = menu_items_by_id['nav-zenodo']
    assert_equal I18n.t('layouts.nav.navigation.link_zenodo_text'), zenodo_item.label
    assert_equal 'connector://zenodo', zenodo_item.icon
    assert_equal 2, zenodo_item.position
    assert zenodo_item.link?

    separator_item = menu_items_by_id['repositories-settings-separator']
    assert_equal '---', separator_item.label
    assert_equal 3, separator_item.position
    assert separator_item.separator?
    assert separator_item.divider?

    settings_item = menu_items_by_id['nav-repo-settings']
    assert_equal I18n.t('layouts.nav.navigation.link_repo_settings_text'), settings_item.label
    assert_equal 'bs://bi-gear-fill', settings_item.icon
    assert_equal 4, settings_item.position
    assert settings_item.link?
  end

  test 'right-aligned navigation items have correct attributes' do
    items = Nav::NavDefaults.navigation_items
    items_by_id = items.index_by(&:id)

    ood_dashboard_item = items_by_id['nav-ood-dashboard']
    assert_equal 'Open OnDemand', ood_dashboard_item.label
    assert_equal 1, ood_dashboard_item.position
    assert ood_dashboard_item.rhs?
    assert ood_dashboard_item.link?
    assert_not_nil ood_dashboard_item.icon
    assert_not_nil ood_dashboard_item.url

    help_dropdown = items_by_id['help']
    assert_equal I18n.t('layouts.nav.navigation.link_help_text'), help_dropdown.label
    assert_equal 2, help_dropdown.position
    assert help_dropdown.rhs?
    assert help_dropdown.menu?
  end

  test 'help dropdown menu has correct structure and items' do
    items = Nav::NavDefaults.navigation_items
    help_item = items.find { |item| item.id == 'help' }

    menu_items = help_item.items
    assert_equal 5, menu_items.size
    
    menu_item_ids = menu_items.map(&:id)
    assert_includes menu_item_ids, 'nav-guide'
    assert_includes menu_item_ids, 'nav-sitemap'
    assert_includes menu_item_ids, 'nav-restart'
    assert_includes menu_item_ids, 'help-reset-separator'
    assert_includes menu_item_ids, 'nav-reset'
  end

  test 'help dropdown menu items have correct attributes' do
    items = Nav::NavDefaults.navigation_items
    help_item = items.find { |item| item.id == 'help' }
    menu_items = help_item.items
    menu_items_by_id = menu_items.index_by(&:id)

    guide_item = menu_items_by_id['nav-guide']
    assert_equal I18n.t('layouts.nav.navigation.link_guide_text'), guide_item.label
    assert_equal 'bs://bi-book', guide_item.icon
    assert_equal 1, guide_item.position
    assert_equal true, guide_item.new_tab
    assert guide_item.link?

    sitemap_item = menu_items_by_id['nav-sitemap']
    assert_equal I18n.t('layouts.nav.navigation.link_sitemap_text'), sitemap_item.label
    assert_equal 'bs://bi-diagram-3', sitemap_item.icon
    assert_equal 2, sitemap_item.position
    assert guide_item.link?

    restart_item = menu_items_by_id['nav-restart']
    assert_equal I18n.t('layouts.nav.navigation.link_restart_text'), restart_item.label
    assert_equal 'bs://bi-bootstrap-reboot', restart_item.icon
    assert_equal 3, restart_item.position
    assert restart_item.link?

    separator_item = menu_items_by_id['help-reset-separator']
    assert_equal '---', separator_item.label
    assert_equal 4, separator_item.position
    assert separator_item.separator?

    reset_item = menu_items_by_id['nav-reset']
    assert_equal I18n.t('layouts.nav.navigation.link_reset_text'), reset_item.label
    assert_equal 'reset_button', reset_item.partial
    assert_equal 5, reset_item.position
    assert reset_item.label? # No URL, so should be a label type
  end

  test 'all navigation items have required attributes' do
    items = Nav::NavDefaults.navigation_items

    items.each do |item|
      assert_not_nil item.id, "Item should have an id"
      assert_not_nil item.position, "Item #{item.id} should have a position"
      assert_includes ['left', 'right'], item.alignment, "Item #{item.id} should have valid alignment"
      
      # Items should either have a URL (link) or menu items (menu) or be a label
      if item.menu?
        assert item.items.any?, "Menu item #{item.id} should have menu items"
      elsif item.link?
        assert_not_nil item.url, "Link item #{item.id} should have a URL"
      else
        assert item.label?, "Item #{item.id} should be a label type"
      end
    end
  end

  test 'navigation urls are generated correctly' do
    items = Nav::NavDefaults.navigation_items
    items_by_id = items.index_by(&:id)

    # Test that URLs are generated using Rails routes
    projects_item = items_by_id['nav-projects']
    assert_equal Rails.application.routes.url_helpers.projects_path, projects_item.url

    downloads_item = items_by_id['nav-downloads']
    assert_equal Rails.application.routes.url_helpers.download_status_path, downloads_item.url

    uploads_item = items_by_id['nav-uploads']
    assert_equal Rails.application.routes.url_helpers.upload_status_path, uploads_item.url
  end

  test 'connector-specific urls contain expected connector types' do
    items = Nav::NavDefaults.navigation_items
    repositories_item = items.find { |item| item.id == 'repositories' }
    menu_items = repositories_item.items
    menu_items_by_id = menu_items.index_by(&:id)

    dataverse_item = menu_items_by_id['nav-dataverse']
    assert_includes dataverse_item.url, ConnectorType::DATAVERSE.to_s

    zenodo_item = menu_items_by_id['nav-zenodo']
    assert_includes zenodo_item.url, ConnectorType::ZENODO.to_s
  end

  test 'navigation items are not hidden by default' do
    items = Nav::NavDefaults.navigation_items

    items.each do |item|
      assert_not item.hidden?, "Item #{item.id} should not be hidden by default"
      
      # Check menu items as well
      if item.menu?
        item.items.each do |menu_item|
          assert_not menu_item.hidden?, "Menu item #{menu_item.id} should not be hidden by default"
        end
      end
    end
  end

  test 'new_tab attribute is set correctly for external links' do
    items = Nav::NavDefaults.navigation_items
    help_item = items.find { |item| item.id == 'help' }
    guide_item = help_item.items.find { |item| item.id == 'nav-guide' }

    # Guide link should open in new tab
    assert_equal true, guide_item.new_tab

    # Most other items should not open in new tab
    projects_item = items.find { |item| item.id == 'nav-projects' }
    assert_equal false, projects_item.new_tab
  end
end