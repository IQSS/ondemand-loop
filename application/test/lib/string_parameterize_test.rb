# frozen_string_literal: true
require 'test_helper'

class StringParameterizeTest < ActiveSupport::TestCase
  test 'should parameterize path-like string' do
    input = '/data/research/my_data.txt'
    expected = 'data_research_my_data_txt'
    assert_equal expected, input.parameterize(separator: '_')
  end

  test 'should parameterize string with spaces' do
    input = 'This is a Test String'
    expected = 'this_is_a_test_string'
    assert_equal expected, input.parameterize(separator: '_')
  end

  test 'should parameterize DOI-like string' do
    input = 'doi:10.70122/FK2/OO7VX1'
    expected = 'doi_10_70122_fk2_oo7vx1'
    assert_equal expected, input.parameterize(separator: '_')
  end

  test 'should parameterize combined complex string' do
    input = '/my data/doi:10.5678/FK2/OO7VX1/test file name.txt'
    expected = 'my_data_doi_10_5678_fk2_oo7vx1_test_file_name_txt'
    assert_equal expected, input.parameterize(separator: '_')
  end
end
