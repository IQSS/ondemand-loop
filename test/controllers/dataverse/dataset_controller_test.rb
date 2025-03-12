require "test_helper"

class Dataverse::DatasetControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get dataverse_dataset_show_url
    assert_response :success
  end
end
