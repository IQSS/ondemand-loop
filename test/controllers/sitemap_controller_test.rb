require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sitemap_url
    assert_response :success
  end
end