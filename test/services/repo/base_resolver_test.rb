require 'test_helper'

class Repo::BaseResolverTest < ActiveSupport::TestCase
  class Dummy < Repo::BaseResolver; end

  test 'build raises' do
    assert_raises(NotImplementedError) { Dummy.build }
  end

  test 'default priority' do
    assert_equal 100, Dummy.new.priority
  end
end
