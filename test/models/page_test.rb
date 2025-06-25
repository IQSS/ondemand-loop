require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "returns items for page" do
    items = (1..20).to_a
    page = Page.new(items, 2, 5)
    assert_equal [6,7,8,9,10], page.page_items
  end

  test "handles invalid page and per_page" do
    page = Page.new((1..3).to_a, 0, 0)
    assert_equal [1,2,3], page.page_items
  end
end
