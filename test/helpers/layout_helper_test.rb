# frozen_string_literal: true
require 'test_helper'

class LayoutHelperTest < ActionView::TestCase
  include LayoutHelper

  test 'on_page? matches controller and action' do
    self.stubs(:params).returns(controller: 'projects', action: 'index')
    assert on_page?(controller: 'projects', action: 'index')
    refute on_page?(controller: 'projects', action: 'show')
  end

  test 'on_project_index? is true only on projects index' do
    self.stubs(:params).returns(controller: 'projects', action: 'index')
    assert on_project_index?
    self.stubs(:params).returns(controller: 'projects', action: 'show')
    refute on_project_index?
  end

  test 'on_explore? detects explore controller' do
    self.stubs(:params).returns(controller: 'explore', action: 'index')
    assert on_explore?
    self.stubs(:params).returns(controller: 'projects', action: 'index')
    refute on_explore?
  end
end
