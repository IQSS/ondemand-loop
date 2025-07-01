# frozen_string_literal: true

class FileSizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(Integer) && value >= 0
      record.errors.add(attribute, 'must be greater than or equal to 0')
      return
    end

    max = resolve_max_size(record)
    return if max.nil?

    if value > max
      record.errors.add(attribute, "is too large (maximum allowed is #{human_size(max)})")
    end
  end

  private

  def resolve_max_size(record)
    raw = options[:max]

    case raw
    when Symbol
      record.public_send(raw)
    when Numeric
      raw
    else
      raise ArgumentError, "Invalid :max option in file_size validator: expected Symbol or Numeric, got #{raw.class}"
    end
  end

  def human_size(bytes)
    ActiveSupport::NumberHelper.number_to_human_size(bytes)
  end
end
