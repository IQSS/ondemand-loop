# frozen_string_literal: true

class ConnectorResult
  attr_reader :data

  def initialize(data = {})
    @data = data || {}
  end

  def message
    data[:message] || {}
  end

  def success?
    data[:success] != false
  end

  def partial
    data[:partial]
  end

  def locals
    data[:locals] || {}
  end

  def [](key)
    data[key]
  end

  def to_h
    data
  end
end
