# frozen_string_literal: true
require 'addressable/uri'

class FluentUrl
  def initialize(base)
    @uri = Addressable::URI.parse(base)
    @segments = [@uri.path || '/']
    @params = {}
  end

  def add_path(part)
    return self if part.blank?

    @segments << Addressable::URI.encode_component(part, Addressable::URI::CharacterClasses::PATH)
    self
  end

  def add_param(key, value)
    @params[key.to_s] = value
    self
  end

  def to_s
    @uri.path = File.join('/', *@segments).chomp('/')
    @uri.query_values = @params unless @params.empty?
    @uri.to_s
  end
end
