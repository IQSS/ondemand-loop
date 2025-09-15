# frozen_string_literal: true

module Nav
  class MainItem
    attr_reader :id, :label, :url, :items, :position, :hidden, :type, :alignment, :new_tab, :icon, :partial

    def initialize(id:, label: nil, url: nil, items: nil, position: nil, hidden: nil, alignment: nil, new_tab: nil, icon: nil, partial: nil)
      @id = id
      @label = label
      @url = url
      @items = items&.map { |child| Nav::MenuItem.new(**child) }
      @position = position
      @hidden = hidden.nil? ? false : hidden
      @type = infer_type
      @alignment = alignment || 'left'
      @new_tab = new_tab.nil? ? false : new_tab
      @icon = icon
      @partial = partial
    end

    def hidden?
      !!@hidden
    end

    def menu?
      type == 'nav_menu'
    end

    def link?
      type == 'nav_link'
    end

    def label?
      type == 'nav_label'
    end

    def lhs?
      alignment == 'left'
    end

    def rhs?
      alignment == 'right'
    end

    def partial_name
      # If a custom partial is specified, use it
      return partial if partial.present?
      
      # Otherwise, use the type directly as it matches the partial name
      type
    end

    def to_h
      {
        id: id,
        label: label,
        url: url,
        items: items&.map(&:to_h),
        position: position,
        hidden: hidden,
        type: type,
        alignment: alignment,
        new_tab: new_tab,
        icon: icon,
        partial: partial
      }.compact
    end

    private

    def infer_type
      if url
        'nav_link'
      elsif items&.any?
        'nav_menu'
      else
        'nav_label'
      end
    end
  end
end