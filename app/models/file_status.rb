# frozen_string_literal: true

# Only use FileStatus.get(value). All instances are singletons.
class FileStatus
  # Define the valid statuses as an array
  STATUS = %w[pending downloading uploading success error cancelled].freeze
  # Private constructor to prevent direct instantiation
  private_class_method :new

  def self.get(value)
    value = value.to_s.downcase
    raise ArgumentError, "Invalid status: #{value}" unless STATUS.include?(value)

    const_get(value.upcase)
  end

  # Initialize with a status value
  def initialize(value)
    value = value.to_s.downcase
    raise ArgumentError, "Invalid status: #{value}" unless STATUS.include?(value)

    @value = value
  end

  # Provide the string representation
  def to_s
    @value
  end

  def completed?
    self.class.completed_statuses.include?(self)
  end

  # Dynamically define constants for each status
  STATUS.each do |status|
    # Define a constant for each status (e.g., FileStatus::PENDING)
    const_set(status.upcase, new(status))
  end

  # Dynamically define methods to check each status
  STATUS.each do |status|
    define_method("#{status}?") do
      @value == status
    end
  end

  def self.new_statuses
    [FileStatus::PENDING]
  end

  def self.completed_statuses
    [FileStatus::SUCCESS, FileStatus::ERROR, FileStatus::CANCELLED]
  end

  def self.retryable_statuses
    [FileStatus::ERROR, FileStatus::CANCELLED]
  end

end
