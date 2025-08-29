class Current < ActiveSupport::CurrentAttributes
  DYNAMIC_ATTRIBUTES = %i[active_project].freeze
  attribute :settings, *DYNAMIC_ATTRIBUTES
end
