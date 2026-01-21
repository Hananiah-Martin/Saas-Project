require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get checkout" do
    get payments_checkout_url
    assert_response :success
  end

  test "should get verify" do
    get payments_verify_url
    assert_response :success
  end
end
