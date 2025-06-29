# frozen_string_literal: true

module DetachedProcessHelper
  def process_status_class(status, type:)
    if status.idle?
      OpenStruct.new(
        button: 'btn-outline-warning',
        icon: type == :download ? 'bi-arrow-down-circle' : 'bi-arrow-up-circle',
        text: 'text-warning-emphasis'
      )
    else
      OpenStruct.new(
        button: 'btn-outline-info',
        icon: type == :download ? 'bi-arrow-down-circle-fill' : 'bi-arrow-up-circle-fill',
        text: 'text-info pulse'
      )
    end
  end

end