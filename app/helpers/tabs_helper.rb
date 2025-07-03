# frozen_string_literal: true

module TabsHelper
  def tab_label_for(object_with_id)
    "tab-label-#{object_with_id.id}"
  end

  def tab_id_for(object_with_id)
    "tab-#{object_with_id.id}"
  end

  def tab_anchor_for(object_with_id)
    "tab-link-#{object_with_id.id}"
  end
end