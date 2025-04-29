# frozen_string_literal: true

class ConnectorType
  TYPES = %w[dataverse].freeze

  # Private constructor to prevent direct instantiation
  private_class_method :new

  def self.get(value)
    value = value.to_s.downcase
    raise ArgumentError, "Invalid type: #{value}" unless TYPES.include?(value)

    const_get(value.upcase)
  end

  # Initialize with a type value
  def initialize(value)
    value = value.to_s.downcase
    raise ArgumentError, "Invalid type: #{value}" unless TYPES.include?(value)

    @value = value
  end

  def to_s
    @value
  end

  # Dynamically define constants for each type
  TYPES.each do |type|
    const_set(type.upcase, new(type))
  end

  # Dynamically define methods to check each type
  TYPES.each do |type|
    define_method("#{type}?") do
      @value == type
    end
  end

end
