# frozen_string_literal: true

module Nav
  class MenuItem
    attr_reader :id, :label, :url, :position, :hidden, :type, :new_tab, :icon, :partial, :custom

    def initialize(id: nil, label: nil, url: nil, position: nil, hidden: nil, type: nil, new_tab: nil, icon: nil, partial: nil, custom: nil)
      @id = id
      @label = label
      @url = url
      @position = position
      @hidden = hidden.nil? ? false : hidden
      @type = type || infer_type
      @new_tab = new_tab.nil? ? false : new_tab
      @icon = icon
      @partial = partial
      @custom = custom.nil? ? false : custom
    end

    def hidden?
      !!@hidden
    end

    def custom?
      !!@custom
    end

    def link?
      type == 'nav_menu_link'
    end

    def label?
      type == 'nav_menu_label'
    end

    def divider?
      type == 'nav_menu_divider'
    end

    def separator?
      divider? || (label == '---')
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
        position: position,
        hidden: hidden,
        type: type,
        new_tab: new_tab,
        icon: icon,
        partial: partial
      }.compact
    end

    private

    def infer_type
      if label == '---'
        'nav_menu_divider'
      elsif url
        'nav_menu_link'
      else
        'nav_menu_label'
      end
    end
  end
end