require 'test_helper'

class PaymentTiersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @payment_tier = payment_tiers(:one)
  end

  test "should get index" do
    sign_in users(:admin)
    get payment_tiers_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:admin)
    get new_payment_tier_url
    assert_response :success
  end

  test "should create payment_tier" do
    sign_in users(:admin)

    assert_difference('PaymentTier.count') do
      post payment_tiers_url, params: { payment_tier: { deposit: @payment_tier.deposit, title: @payment_tier.title, tuition: @payment_tier.tuition } }
    end

    assert_redirected_to payment_tier_url(PaymentTier.last)
  end

  test "should show payment_tier" do
    sign_in users(:admin)
    get payment_tier_url(@payment_tier)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    get edit_payment_tier_url(@payment_tier)
    assert_response :success
  end

  test "should update payment_tier" do
    sign_in users(:admin)
    patch payment_tier_url(@payment_tier), params: { payment_tier: { deposit: @payment_tier.deposit, title: @payment_tier.title, tuition: @payment_tier.tuition } }
    assert_redirected_to payment_tier_url(@payment_tier)
  end

  test "should destroy payment_tier" do
    # Prevent referencing classes from interfering
    @payment_tier.klasses.each do |klass|
      AppForm.where(klass: klass).destroy_all
      klass.destroy
    end

    sign_in users(:admin)
    assert_difference('PaymentTier.count', -1) do
      delete payment_tier_url(@payment_tier)
    end

    assert_redirected_to payment_tiers_url
  end
end
