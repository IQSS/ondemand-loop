# frozen_string_literal: true

require 'test_helper'

class Nav::MenuItemTest < ActiveSupport::TestCase
  test 'initialize creates menu item with basic attributes' do
    item = Nav::MenuItem.new(
      id: 'menu-item',
      label: 'Menu Item',
      url: '/menu-item',
      position: 2
    )

    assert_equal 'menu-item', item.id
    assert_equal 'Menu Item', item.label
    assert_equal '/menu-item', item.url
    assert_equal 2, item.position
    assert_equal false, item.hidden
    assert_equal false, item.new_tab
  end

  test 'initialize sets default values when not provided' do
    item = Nav::MenuItem.new(id: 'minimal-menu-item')

    assert_equal 'minimal-menu-item', item.id
    assert_nil item.label
    assert_nil item.url
    assert_nil item.position
    assert_equal false, item.hidden
    assert_equal false, item.new_tab
    assert_equal false, item.custom
    assert_nil item.icon
    assert_nil item.partial
  end

  test 'infer_type returns nav_menu_divider for separator label' do
    divider = Nav::MenuItem.new(
      id: 'divider',
      label: '---'
    )

    assert_equal 'nav_menu_divider', divider.type
    assert divider.divider?
    assert divider.separator?
    assert_not divider.link?
    assert_not divider.label?
  end

  test 'infer_type returns nav_menu_link when url is provided' do
    link_item = Nav::MenuItem.new(
      id: 'menu-link',
      url: '/menu-path'
    )

    assert_equal 'nav_menu_link', link_item.type
    assert link_item.link?
    assert_not link_item.divider?
    assert_not link_item.label?
    assert_not link_item.separator?
  end

  test 'infer_type returns nav_menu_label when no url and not divider' do
    label_item = Nav::MenuItem.new(
      id: 'menu-label',
      label: 'Section Header'
    )

    assert_equal 'nav_menu_label', label_item.type
    assert label_item.label?
    assert_not label_item.link?
    assert_not label_item.divider?
    assert_not label_item.separator?
  end

  test 'explicit type overrides inferred type' do
    item = Nav::MenuItem.new(
      id: 'custom-type',
      url: '/path',  # This would normally infer nav_menu_link
      type: 'custom_menu_type'
    )

    assert_equal 'custom_menu_type', item.type
    assert_not item.link?  # Since type is custom, not nav_menu_link
  end

  test 'hidden? returns correct boolean value' do
    visible_item = Nav::MenuItem.new(id: 'visible')
    hidden_item = Nav::MenuItem.new(id: 'hidden', hidden: true)
    explicit_visible_item = Nav::MenuItem.new(id: 'explicit-visible', hidden: false)

    assert_not visible_item.hidden?
    assert hidden_item.hidden?
    assert_not explicit_visible_item.hidden?
  end

  test 'separator? returns true for dividers and --- label' do
    divider_by_type = Nav::MenuItem.new(id: 'div1', type: 'nav_menu_divider')
    divider_by_label = Nav::MenuItem.new(id: 'div2', label: '---')
    regular_item = Nav::MenuItem.new(id: 'regular', label: 'Regular Item')

    assert divider_by_type.separator?
    assert divider_by_label.separator?
    assert_not regular_item.separator?
  end

  test 'partial_name returns custom partial when specified' do
    item = Nav::MenuItem.new(
      id: 'custom-partial-menu',
      partial: 'custom_menu_partial'
    )

    assert_equal 'custom_menu_partial', item.partial_name
  end

  test 'partial_name returns type when no custom partial' do
    link_item = Nav::MenuItem.new(id: 'link', url: '/path')
    divider_item = Nav::MenuItem.new(id: 'divider', label: '---')
    label_item = Nav::MenuItem.new(id: 'label', label: 'Label')

    assert_equal 'nav_menu_link', link_item.partial_name
    assert_equal 'nav_menu_divider', divider_item.partial_name
    assert_equal 'nav_menu_label', label_item.partial_name
  end

  test 'to_h returns hash representation with all attributes' do
    item = Nav::MenuItem.new(
      id: 'full-menu-item',
      label: 'Full Menu Item',
      url: '/full-menu',
      position: 3,
      hidden: false,
      type: 'nav_menu_link',
      new_tab: true,
      icon: 'menu-icon-path',
      partial: 'custom_menu_partial'
    )

    hash = item.to_h

    assert_equal 'full-menu-item', hash[:id]
    assert_equal 'Full Menu Item', hash[:label]
    assert_equal '/full-menu', hash[:url]
    assert_equal 3, hash[:position]
    assert_equal false, hash[:hidden]
    assert_equal 'nav_menu_link', hash[:type]
    assert_equal true, hash[:new_tab]
    assert_equal 'menu-icon-path', hash[:icon]
    assert_equal 'custom_menu_partial', hash[:partial]
  end

  test 'to_h excludes nil values with compact' do
    minimal_item = Nav::MenuItem.new(id: 'minimal-menu')
    hash = minimal_item.to_h

    assert_equal 'minimal-menu', hash[:id]
    assert_equal 'nav_menu_label', hash[:type]
    assert_equal false, hash[:hidden]
    assert_equal false, hash[:new_tab]
    
    # These should not be present due to compact
    assert_not hash.key?(:label)
    assert_not hash.key?(:url)
    assert_not hash.key?(:position)
    assert_not hash.key?(:icon)
    assert_not hash.key?(:partial)
  end

  test 'to_h excludes custom attribute from hash output' do
    custom_item = Nav::MenuItem.new(id: 'custom-menu-test', custom: true)
    non_custom_item = Nav::MenuItem.new(id: 'non-custom-menu-test', custom: false)

    custom_hash = custom_item.to_h
    non_custom_hash = non_custom_item.to_h

    # custom attribute should not be included in hash output
    assert_not custom_hash.key?(:custom)
    assert_not non_custom_hash.key?(:custom)
    
    # But custom? method should still work on the objects
    assert custom_item.custom?
    assert_not non_custom_item.custom?
  end

  test 'new_tab defaults to false but can be set to true' do
    default_item = Nav::MenuItem.new(id: 'default-menu')
    new_tab_item = Nav::MenuItem.new(id: 'new-tab-menu', new_tab: true)
    explicit_same_tab = Nav::MenuItem.new(id: 'same-tab-menu', new_tab: false)

    assert_equal false, default_item.new_tab
    assert_equal true, new_tab_item.new_tab
    assert_equal false, explicit_same_tab.new_tab
  end

  test 'different separator representations are recognized' do
    # Test various ways to create separators
    explicit_divider = Nav::MenuItem.new(id: 'sep1', type: 'nav_menu_divider')
    dash_separator = Nav::MenuItem.new(id: 'sep2', label: '---')
    inferred_divider = Nav::MenuItem.new(id: 'sep3', label: '---') # Should auto-infer type

    assert explicit_divider.divider?
    assert explicit_divider.separator?
    
    assert dash_separator.separator?
    assert_equal 'nav_menu_divider', dash_separator.type
    
    assert inferred_divider.divider?
    assert inferred_divider.separator?
    assert_equal 'nav_menu_divider', inferred_divider.type
  end

  test 'icon and position attributes are stored correctly' do
    item = Nav::MenuItem.new(
      id: 'icon-item',
      label: 'Icon Item',
      icon: 'bs://bi-house',
      position: 99
    )

    assert_equal 'bs://bi-house', item.icon
    assert_equal 99, item.position
  end

  test 'custom defaults to false but can be set to true' do
    default_item = Nav::MenuItem.new(id: 'default-menu')
    custom_item = Nav::MenuItem.new(id: 'custom-menu', custom: true)
    explicit_non_custom = Nav::MenuItem.new(id: 'non-custom-menu', custom: false)

    assert_equal false, default_item.custom
    assert_equal true, custom_item.custom
    assert_equal false, explicit_non_custom.custom
  end

  test 'custom? returns correct boolean value' do
    default_item = Nav::MenuItem.new(id: 'default-menu')
    custom_item = Nav::MenuItem.new(id: 'custom-menu', custom: true)
    explicit_non_custom = Nav::MenuItem.new(id: 'non-custom-menu', custom: false)

    assert_not default_item.custom?
    assert custom_item.custom?
    assert_not explicit_non_custom.custom?
  end
end