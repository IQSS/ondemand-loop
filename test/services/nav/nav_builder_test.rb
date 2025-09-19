# frozen_string_literal: true

require 'test_helper'

class Nav::NavBuilderTest < ActiveSupport::TestCase
  def setup
    # Create some default navigation items for testing
    @default_items = [
      Nav::MainItem.new(
        id: 'nav-projects',
        label: 'Projects',
        url: '/projects',
        position: 1
      ),
      Nav::MainItem.new(
        id: 'nav-downloads',
        label: 'Downloads',
        url: '/downloads',
        position: 2
      ),
      Nav::MainItem.new(
        id: 'repositories-dropdown',
        label: 'Repositories',
        items: [
          { id: 'nav-dataverse', label: 'Dataverse', url: '/dataverse', position: 1 },
          { id: 'nav-zenodo', label: 'Zenodo', url: '/zenodo', position: 2 }
        ],
        position: 3
      )
    ]
  end

  test 'build class method creates instance and calls build' do
    defaults = [@default_items.first]
    overrides = []
    
    result = Nav::NavBuilder.build(defaults, overrides)
    
    assert_instance_of Array, result
    assert_equal 1, result.size
    assert_equal 'nav-projects', result.first.id
  end

  test 'build with no overrides returns defaults without hidden items' do
    # Add a hidden item to test filtering
    hidden_item = Nav::MainItem.new(id: 'hidden-item', label: 'Hidden', hidden: true, position: 4)
    defaults = @default_items + [hidden_item]
    
    result = Nav::NavBuilder.build(defaults, [])
    
    assert_equal 3, result.size # Should exclude hidden item
    result_ids = result.map(&:id)
    assert_includes result_ids, 'nav-projects'
    assert_includes result_ids, 'nav-downloads'
    assert_includes result_ids, 'repositories-dropdown'
    assert_not_includes result_ids, 'hidden-item'
  end

  test 'build returns items sorted by position' do
    # Create items with different positions
    unsorted_defaults = [
      Nav::MainItem.new(id: 'item3', label: 'Third', position: 3),
      Nav::MainItem.new(id: 'item1', label: 'First', position: 1),
      Nav::MainItem.new(id: 'item2', label: 'Second', position: 2)
    ]
    
    result = Nav::NavBuilder.build(unsorted_defaults, [])
    
    assert_equal ['item1', 'item2', 'item3'], result.map(&:id)
  end

  test 'build handles items without position by sorting them last' do
    defaults = [
      Nav::MainItem.new(id: 'positioned', label: 'Has Position', position: 1),
      Nav::MainItem.new(id: 'no-position', label: 'No Position')
    ]
    
    result = Nav::NavBuilder.build(defaults, [])
    
    assert_equal 'positioned', result.first.id
    assert_equal 'no-position', result.last.id
  end

  test 'override existing item preserves id and merges attributes' do
    overrides = [
      { id: 'nav-projects', label: 'Custom Projects', url: '/custom-projects' }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    projects_item = result.find { |item| item.id == 'nav-projects' }
    assert_equal 'Custom Projects', projects_item.label
    assert_equal '/custom-projects', projects_item.url
    assert_equal 1, projects_item.position # Preserved from default
  end

  test 'override can hide existing item' do
    overrides = [
      { id: 'nav-downloads', hidden: true }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    result_ids = result.map(&:id)
    assert_not_includes result_ids, 'nav-downloads'
    assert_includes result_ids, 'nav-projects'
  end

  test 'add new item when id does not match existing' do
    overrides = [
      { id: 'nav-custom', label: 'Custom Item', url: '/custom', position: 5 }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    assert_equal 4, result.size
    custom_item = result.find { |item| item.id == 'nav-custom' }
    assert_not_nil custom_item
    assert_equal 'Custom Item', custom_item.label
    assert_equal '/custom', custom_item.url
    assert_equal 5, custom_item.position
  end

  test 'add new item generates id when not provided' do
    overrides = [
      { label: 'No ID Item', url: '/no-id' }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    assert_equal 4, result.size
    new_item = result.find { |item| item.id.start_with?('new_item_') }
    assert_not_nil new_item
    assert_equal 'No ID Item', new_item.label
  end

  test 'merge menu items in dropdown navigation' do
    overrides = [
      {
        id: 'repositories-dropdown',
        items: [
          { id: 'nav-dataverse', label: 'Custom Dataverse' }, # Override existing
          { id: 'nav-custom-repo', label: 'Custom Repo', url: '/custom-repo', position: 3 } # Add new
        ]
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    repos_item = result.find { |item| item.id == 'repositories-dropdown' }
    menu_items = repos_item.items
    menu_items_by_id = menu_items.index_by(&:id)
    
    # Check overridden item
    dataverse_item = menu_items_by_id['nav-dataverse']
    assert_equal 'Custom Dataverse', dataverse_item.label
    assert_equal 1, dataverse_item.position # Position preserved
    
    # Check original item still exists
    zenodo_item = menu_items_by_id['nav-zenodo']
    assert_equal 'Zenodo', zenodo_item.label
    
    # Check new item added
    custom_item = menu_items_by_id['nav-custom-repo']
    assert_not_nil custom_item
    assert_equal 'Custom Repo', custom_item.label
  end

  test 'hide menu item in dropdown' do
    overrides = [
      {
        id: 'repositories-dropdown',
        items: [
          { id: 'nav-zenodo', hidden: true }
        ]
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    repos_item = result.find { |item| item.id == 'repositories-dropdown' }
    menu_item_ids = repos_item.items.map(&:id)
    
    assert_includes menu_item_ids, 'nav-dataverse'
    assert_not_includes menu_item_ids, 'nav-zenodo'
  end

  test 'add new menu item without id generates random id' do
    overrides = [
      {
        id: 'repositories-dropdown',
        items: [
          { label: 'No ID Menu Item', url: '/no-id-menu' }
        ]
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    repos_item = result.find { |item| item.id == 'repositories-dropdown' }
    new_menu_item = repos_item.items.find { |item| item.id.start_with?('new_menu_item_') }
    
    assert_not_nil new_menu_item
    assert_equal 'No ID Menu Item', new_menu_item.label
  end

  test 'menu items are sorted by position within dropdown' do
    overrides = [
      {
        id: 'repositories-dropdown',
        items: [
          { id: 'first-item', label: 'First', position: 0 },
          { id: 'last-item', label: 'Last', position: 10 }
        ]
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    repos_item = result.find { |item| item.id == 'repositories-dropdown' }
    menu_item_ids = repos_item.items.map(&:id)
    
    assert_equal 'first-item', menu_item_ids.first
    assert_equal 'last-item', menu_item_ids.last
  end

  test 'new items are prioritized in sort order' do
    defaults = [
      Nav::MainItem.new(id: 'existing1', position: 1),
      Nav::MainItem.new(id: 'existing2', position: 2)
    ]
    
    overrides = [
      { id: 'new_item_abc123', label: 'New Item', position: 1 }
    ]
    
    result = Nav::NavBuilder.build(defaults, overrides)
    
    # New items should come before existing items at same position
    assert_equal 'new_item_abc123', result.first.id
  end

  test 'override all attributes of existing item' do
    overrides = [
      {
        id: 'nav-projects',
        label: 'Custom Projects',
        url: '/custom',
        position: 99,
        hidden: false,
        alignment: 'right',
        new_tab: true,
        icon: 'custom-icon',
        partial: 'custom_partial'
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    projects_item = result.find { |item| item.id == 'nav-projects' }
    assert_equal 'Custom Projects', projects_item.label
    assert_equal '/custom', projects_item.url
    assert_equal 99, projects_item.position
    assert_equal false, projects_item.hidden
    assert_equal 'right', projects_item.alignment
    assert_equal true, projects_item.new_tab
    assert_equal 'custom-icon', projects_item.icon
    assert_equal 'custom_partial', projects_item.partial
  end

  test 'initialize handles non-array defaults and overrides' do
    single_default = Nav::MainItem.new(id: 'single', label: 'Single')
    single_override = [{ id: 'single', label: 'Overridden' }]
    
    builder = Nav::NavBuilder.new(single_default, single_override)
    result = builder.build
    
    assert_equal 1, result.size
    assert_equal 'Overridden', result.first.label
  end

  test 'handles empty defaults and overrides' do
    result = Nav::NavBuilder.build([], [])
    assert_equal [], result
    
    result = Nav::NavBuilder.build(nil, nil)
    assert_equal [], result
  end

  test 'merge preserves nil values when override not provided' do
    default_item = Nav::MainItem.new(
      id: 'test-item',
      label: 'Test',
      position: 1
      # No url, icon, partial specified
    )
    
    override = { id: 'test-item', label: 'New Label' }
    
    result = Nav::NavBuilder.build([default_item], [override])
    
    item = result.first
    assert_equal 'New Label', item.label
    assert_nil item.url
    assert_nil item.icon
    assert_nil item.partial
    assert_equal 1, item.position
  end

  test 'complex navigation override scenario' do
    # Test a realistic scenario with multiple types of overrides
    overrides = [
      { id: 'nav-projects', label: 'My Projects' }, # Override existing
      { id: 'nav-downloads', hidden: true }, # Hide existing
      { id: 'nav-custom', label: 'Custom', url: '/custom', position: 4 }, # Add new
      {
        id: 'repositories-dropdown',
        label: 'Data Repositories',
        items: [
          { id: 'nav-dataverse', icon: 'custom-dataverse-icon' }, # Override menu item
          { id: 'nav-separator', label: '---', position: 1.5 }, # Add menu separator
          { id: 'nav-zenodo', hidden: true } # Hide menu item
        ]
      }
    ]
    
    result = Nav::NavBuilder.build(@default_items, overrides)
    
    # Check main items
    assert_equal 3, result.size # downloads hidden, custom added
    result_by_id = result.index_by(&:id)
    
    assert_equal 'My Projects', result_by_id['nav-projects'].label
    assert_not_includes result.map(&:id), 'nav-downloads'
    assert_equal 'Custom', result_by_id['nav-custom'].label
    
    # Check dropdown
    repos_item = result_by_id['repositories-dropdown']
    assert_equal 'Data Repositories', repos_item.label
    
    menu_items_by_id = repos_item.items.index_by(&:id)
    assert_equal 'custom-dataverse-icon', menu_items_by_id['nav-dataverse'].icon
    assert_equal '---', menu_items_by_id['nav-separator'].label
    assert_not_includes repos_item.items.map(&:id), 'nav-zenodo'
  end

  test 'boolean merging handles falsy values correctly' do
    # Create default item with true values
    default_item = Nav::MainItem.new(
      id: 'test-bool',
      label: 'Test',
      hidden: true,
      new_tab: true,
      position: 1
    )
    
    # Override with explicit false values
    overrides = [
      { id: 'test-bool', hidden: false, new_tab: false }
    ]
    
    result = Nav::NavBuilder.build([default_item], overrides)
    
    # Should include the item (not hidden) and the override values should be respected
    assert_equal 1, result.size
    item = result.first
    assert_equal 'test-bool', item.id
    assert_equal false, item.hidden  # Override false should be used, not default true
    assert_equal false, item.new_tab # Override false should be used, not default true
  end

  test 'menu item boolean merging handles falsy values correctly' do
    # Create default with menu items having true values
    default_item = Nav::MainItem.new(
      id: 'dropdown-test',
      label: 'Test Dropdown',
      items: [
        { id: 'menu1', label: 'Menu 1', hidden: true, new_tab: true, position: 1 }
      ],
      position: 1
    )
    
    # Override menu item with explicit false values
    overrides = [
      {
        id: 'dropdown-test',
        items: [
          { id: 'menu1', hidden: false, new_tab: false }
        ]
      }
    ]
    
    result = Nav::NavBuilder.build([default_item], overrides)
    
    item = result.first
    menu_item = item.items.first
    assert_equal false, menu_item.hidden  # Override false should be used, not default true
    assert_equal false, menu_item.new_tab # Override false should be used, not default true
  end
end