# frozen_string_literal: true

module TabsHelper
  def tab_label_for(object_with_id)
    "tab-label-#{object_with_id.id}"
  end

  # Returns just the anchor ID, e.g. "tab-123"
  def tab_anchor_for(object_with_id)
    "tab-#{object_with_id.id}"
  end

  # Returns a full href string, e.g. "#tab-123"
  def tab_href_for(object_with_id)
    "##{tab_anchor_for(object_with_id)}"
  end
end