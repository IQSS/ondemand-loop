# frozen_string_literal: true

require 'test_helper'

class Nav::MainItemTest < ActiveSupport::TestCase
  test 'initialize creates main item with basic attributes' do
    item = Nav::MainItem.new(
      id: 'test-item',
      label: 'Test Item',
      url: '/test',
      position: 1
    )

    assert_equal 'test-item', item.id
    assert_equal 'Test Item', item.label
    assert_equal '/test', item.url
    assert_equal 1, item.position
    assert_equal 'left', item.alignment
    assert_equal false, item.hidden
    assert_equal false, item.new_tab
  end

  test 'initialize sets default values when not provided' do
    item = Nav::MainItem.new(id: 'minimal-item')

    assert_equal 'minimal-item', item.id
    assert_nil item.label
    assert_nil item.url
    assert_nil item.position
    assert_equal 'left', item.alignment
    assert_equal false, item.hidden
    assert_equal false, item.new_tab
    assert_equal false, item.custom
    assert_nil item.icon
    assert_nil item.partial
  end

  test 'initialize with right alignment' do
    item = Nav::MainItem.new(
      id: 'right-item',
      alignment: 'right'
    )

    assert_equal 'right', item.alignment
    assert item.rhs?
    assert_not item.lhs?
  end

  test 'initialize with menu items creates Nav::MenuItem objects' do
    menu_items = [
      { id: 'sub1', label: 'Sub Item 1', url: '/sub1' },
      { id: 'sub2', label: 'Sub Item 2', url: '/sub2' }
    ]

    item = Nav::MainItem.new(
      id: 'dropdown',
      label: 'Dropdown',
      items: menu_items
    )

    assert_equal 2, item.items.size
    assert item.items.all? { |sub_item| sub_item.is_a?(Nav::MenuItem) }
    assert_equal 'sub1', item.items.first.id
    assert_equal 'Sub Item 1', item.items.first.label
  end

  test 'infer_type returns nav_link when url is provided' do
    item = Nav::MainItem.new(
      id: 'link-item',
      url: '/some-path'
    )

    assert_equal 'nav_link', item.type
    assert item.link?
    assert_not item.menu?
    assert_not item.label?
  end

  test 'infer_type returns nav_menu when items are provided' do
    item = Nav::MainItem.new(
      id: 'menu-item',
      items: [{ id: 'sub', label: 'Sub' }]
    )

    assert_equal 'nav_menu', item.type
    assert item.menu?
    assert_not item.link?
    assert_not item.label?
  end

  test 'infer_type returns nav_label when no url or items' do
    item = Nav::MainItem.new(
      id: 'label-item',
      label: 'Just a Label'
    )

    assert_equal 'nav_label', item.type
    assert item.label?
    assert_not item.link?
    assert_not item.menu?
  end

  test 'infer_type prioritizes url over items when both are present' do
    item = Nav::MainItem.new(
      id: 'mixed-item',
      url: '/path',
      items: [{ id: 'sub', label: 'Sub Item' }]
    )

    # url takes precedence in type inference
    assert_equal 'nav_link', item.type
    assert item.link?
    assert_not item.menu?
    
    # But items are still available
    assert_equal 1, item.items.size
    assert_equal 'sub', item.items.first.id
  end

  test 'hidden? returns correct boolean value' do
    visible_item = Nav::MainItem.new(id: 'visible')
    hidden_item = Nav::MainItem.new(id: 'hidden', hidden: true)
    explicit_visible_item = Nav::MainItem.new(id: 'explicit-visible', hidden: false)

    assert_not visible_item.hidden?
    assert hidden_item.hidden?
    assert_not explicit_visible_item.hidden?
  end

  test 'lhs? and rhs? return correct alignment values' do
    left_item = Nav::MainItem.new(id: 'left')
    right_item = Nav::MainItem.new(id: 'right', alignment: 'right')

    assert left_item.lhs?
    assert_not left_item.rhs?
    assert_not right_item.lhs?
    assert right_item.rhs?
  end

  test 'partial_name returns custom partial when specified' do
    item = Nav::MainItem.new(
      id: 'custom-partial',
      partial: 'custom_nav_component'
    )

    assert_equal 'custom_nav_component', item.partial_name
  end

  test 'partial_name returns type when no custom partial' do
    link_item = Nav::MainItem.new(id: 'link', url: '/path')
    menu_item = Nav::MainItem.new(id: 'menu', items: [{ id: 'sub' }])
    label_item = Nav::MainItem.new(id: 'label')

    assert_equal 'nav_link', link_item.partial_name
    assert_equal 'nav_menu', menu_item.partial_name
    assert_equal 'nav_label', label_item.partial_name
  end

  test 'to_h returns hash representation with all attributes' do
    item = Nav::MainItem.new(
      id: 'full-item',
      label: 'Full Item',
      url: '/full',
      items: [{ id: 'sub', label: 'Sub' }],
      position: 5,
      hidden: false,
      alignment: 'right',
      new_tab: true,
      icon: 'icon-path',
      partial: 'custom_partial'
    )

    hash = item.to_h

    assert_equal 'full-item', hash[:id]
    assert_equal 'Full Item', hash[:label]
    assert_equal '/full', hash[:url]
    assert_equal 1, hash[:items].size
    assert_equal 'sub', hash[:items].first[:id]
    assert_equal 5, hash[:position]
    assert_equal false, hash[:hidden]
    assert_equal 'nav_link', hash[:type]  # url takes precedence over items in type inference
    assert_equal 'right', hash[:alignment]
    assert_equal true, hash[:new_tab]
    assert_equal 'icon-path', hash[:icon]
    assert_equal 'custom_partial', hash[:partial]
  end

  test 'to_h excludes nil values with compact' do
    minimal_item = Nav::MainItem.new(id: 'minimal')
    hash = minimal_item.to_h

    assert_equal 'minimal', hash[:id]
    assert_equal 'nav_label', hash[:type]
    assert_equal 'left', hash[:alignment]
    assert_equal false, hash[:hidden]
    assert_equal false, hash[:new_tab]
    
    # These should not be present due to compact
    assert_not hash.key?(:label)
    assert_not hash.key?(:url)
    assert_not hash.key?(:items)
    assert_not hash.key?(:position)
    assert_not hash.key?(:icon)
    assert_not hash.key?(:partial)
  end

  test 'to_h excludes custom attribute from hash output' do
    custom_item = Nav::MainItem.new(id: 'custom-test', custom: true)
    non_custom_item = Nav::MainItem.new(id: 'non-custom-test', custom: false)

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
    default_item = Nav::MainItem.new(id: 'default')
    new_tab_item = Nav::MainItem.new(id: 'new-tab', new_tab: true)
    explicit_same_tab = Nav::MainItem.new(id: 'same-tab', new_tab: false)

    assert_equal false, default_item.new_tab
    assert_equal true, new_tab_item.new_tab
    assert_equal false, explicit_same_tab.new_tab
  end

  test 'custom defaults to false but can be set to true' do
    default_item = Nav::MainItem.new(id: 'default')
    custom_item = Nav::MainItem.new(id: 'custom', custom: true)
    explicit_non_custom = Nav::MainItem.new(id: 'non-custom', custom: false)

    assert_equal false, default_item.custom
    assert_equal true, custom_item.custom
    assert_equal false, explicit_non_custom.custom
  end

  test 'custom? returns correct boolean value' do
    default_item = Nav::MainItem.new(id: 'default')
    custom_item = Nav::MainItem.new(id: 'custom', custom: true)
    explicit_non_custom = Nav::MainItem.new(id: 'non-custom', custom: false)

    assert_not default_item.custom?
    assert custom_item.custom?
    assert_not explicit_non_custom.custom?
  end
end