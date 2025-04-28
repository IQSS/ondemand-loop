# frozen_string_literal: true

class ConnectorType
  TYPES = %w[dataverse].freeze

  attr_reader :value

  def initialize(value)
    value = value.to_s.downcase
    raise ArgumentError, "Invalid type: #{value}" unless TYPES.include?(value)

    @value = value
  end

  # Method for checking specific type
  def dataverse?
    value == 'dataverse'
  end

  def to_s
    value
  end
end
