# frozen_string_literal: true
require 'test_helper'

class ProjectNameGeneratorTest < ActiveSupport::TestCase
  test 'should generate a name with default format' do
    name = ProjectNameGenerator.generate
    assert_match(/\A[a-z]+-[a-z]+\z/, name, "Expected format 'adjective-noun'")
  end

  test 'should generate a name with token if specified' do
    name = ProjectNameGenerator.generate(token_length: 4)
    assert_match(/\A[a-z]+-[a-z]+-\d{4}\z/, name, "Expected format 'adjective-noun-####'")
  end

  test 'should use custom delimiter when provided' do
    name = ProjectNameGenerator.generate(delimiter: '_')
    assert_match(/\A[a-z]+_[a-z]+\z/, name, "Expected format 'adjective_noun'")
  end

  test 'should pick adjectives and nouns from defined lists' do
    name = ProjectNameGenerator.generate
    adjective, noun = name.split('-')
    assert_includes ProjectNameGenerator.send(:adjectives), adjective
    assert_includes ProjectNameGenerator.send(:nouns), noun
  end

  test 'should not generate nil or empty names' do
    name = ProjectNameGenerator.generate
    refute_nil name
    refute_empty name
  end
end
