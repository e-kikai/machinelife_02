require "test_helper"

class HelpsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get helps_index_url
    assert_response :success
  end

  test "should get show" do
    get helps_show_url
    assert_response :success
  end
end
