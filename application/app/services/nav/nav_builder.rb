# frozen_string_literal: true

module Nav
  class NavBuilder
    def self.build(defaults, overrides)
      builder = new(defaults, overrides)
      builder.build
    end

    def initialize(defaults, overrides)
      @defaults = Array(defaults)
      @overrides = Array(overrides)
    end

    def build
      # Start with defaults, apply overrides, add new items, then sort
      merged_items = apply_overrides_and_add_new_items
      sort_items(merged_items)
    end

    private

    def apply_overrides_and_add_new_items
      defaults_by_id = @defaults.index_by(&:id)
      result = {}

      # Start with all default items
      @defaults.each { |item| result[item.id] = item }

      # Process each override/new item
      @overrides.each do |override_hash|
        id = override_hash[:id]

        if id && defaults_by_id.key?(id)
          # Override existing item
          merged_item = merge_main_item(defaults_by_id[id], override_hash)
          result[id] = merged_item
        else
          # New item (either no id provided or id doesn't match existing)
          new_item = create_main_item_from_hash(override_hash)
          result[new_item.id] = new_item
        end
      end

      result.values
    end

    def merge_main_item(default_item, override_hash)
      # Extract items for special handling
      override_items = override_hash[:items]

      # Merge menu items if provided
      merged_items = if override_items
                       merge_menu_items(default_item.items || [], override_items)
                     else
                       default_item.items
                     end

      # Create new MainItem with merged attributes
      Nav::MainItem.new(
        id: default_item.id,
        label: override_hash[:label] || default_item.label,
        url: override_hash[:url] || default_item.url,
        items: merged_items&.map(&:to_h), # Convert back to hashes for MainItem constructor
        position: override_hash[:position] || default_item.position,
        hidden: override_hash[:hidden] || default_item.hidden,
        alignment: override_hash[:alignment] || default_item.alignment,
        new_tab: override_hash[:new_tab] || default_item.new_tab,
        icon: override_hash[:icon] || default_item.icon,
        partial: override_hash[:partial] || default_item.partial
      )
    end

    def merge_menu_items(default_items, override_items)
      defaults_by_id = default_items.index_by(&:id)
      result = {}

      # Start with all default menu items
      default_items.each { |item| result[item.id] = item }

      # Process override/new menu items
      Array(override_items).each do |override_hash|
        id = override_hash[:id]

        if id && defaults_by_id.key?(id)
          # Override existing menu item
          result[id] = merge_menu_item(defaults_by_id[id], override_hash)
        else
          # New menu item
          new_item = create_menu_item_from_hash(override_hash)
          item_id = id || "new_menu_item_#{SecureRandom.hex(4)}"
          result[item_id] = new_item
        end
      end

      sort_menu_items(result.values)
    end

    def merge_menu_item(default_item, override_hash)
      Nav::MenuItem.new(
        id: default_item.id,
        label: override_hash[:label] || default_item.label,
        url: override_hash[:url] || default_item.url,
        position: override_hash[:position] || default_item.position,
        hidden: override_hash[:hidden] || default_item.hidden,
        new_tab: override_hash[:new_tab] || default_item.new_tab,
        icon: override_hash[:icon] || default_item.icon,
        partial: override_hash[:partial] || default_item.partial
      )
    end

    def create_main_item_from_hash(hash)
      Nav::MainItem.new(
        id: hash[:id] || "new_item_#{SecureRandom.hex(4)}",
        label: hash[:label],
        url: hash[:url],
        items: hash[:items],
        position: hash[:position],
        hidden: hash[:hidden],
        alignment: hash[:alignment],
        new_tab: hash[:new_tab],
        icon: hash[:icon],
        partial: hash[:partial]
      )
    end

    def create_menu_item_from_hash(hash)
      Nav::MenuItem.new(
        id: hash[:id] || "new_menu_item_#{SecureRandom.hex(4)}",
        label: hash[:label],
        url: hash[:url],
        position: hash[:position],
        hidden: hash[:hidden],
        new_tab: hash[:new_tab],
        icon: hash[:icon],
        partial: hash[:partial]
      )
    end

    def sort_items(items)
      items
        .reject(&:hidden?)
        .sort_by { |item| [item.position || Float::INFINITY, item.id.start_with?('new_item_') ? 0 : 1, item.id] }
    end

    def sort_menu_items(items)
      items
        .reject(&:hidden?)
        .sort_by { |item| [item.position || Float::INFINITY, item.id.start_with?('new_menu_item_') ? 0 : 1, item.id] }
    end
  end
end
