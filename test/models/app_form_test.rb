require 'test_helper'

class AppFormTest < ActiveSupport::TestCase
  setup do
    @appform = app_forms(:two)
    @appform.aasm_state = 'admit_email_sent'
  end

  test "Payment event doesn't progress status if balance is below" do
    @appform.payment
    assert_equal 'admit_email_sent', @appform.aasm_state
  end

  test "Payment progresses status when deposit is paid" do
    @appform.paid = 10
    @appform.payment
    assert_equal 'deposit_paid', @appform.aasm_state
  end
  
  test "Payment progresses status when tuition is paid" do
    @appform.paid = 20
    @appform.payment
    assert_equal 'tuition_paid', @appform.aasm_state 
  end
end
