# frozen_string_literal: true

module FileDropHelper

  def file_drop_target_id(bundle)
    "fbt-#{bundle.id}"
  end

  def file_drop_browser_id(bundle)
    "fb-#{bundle.id}"
  end

end