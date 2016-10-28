require 'test_helper'

class EmailRulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @email_rule = email_rules(:one)
  end

  test "should get index" do
    get email_rules_url
    assert_response :success
  end

  test "should get new" do
    get new_email_rule_url
    assert_response :success
  end

  test "should create email_rule" do
    assert_difference('EmailRule.count') do
      post email_rules_url, params: { email_rule: { copy_team: @email_rule.copy_team, email_template_id: @email_rule.email_template_id, klass_id: @email_rule.klass_id, state: @email_rule.state } }
    end

    assert_redirected_to email_rule_url(EmailRule.last)
  end

  test "should show email_rule" do
    get email_rule_url(@email_rule)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_rule_url(@email_rule)
    assert_response :success
  end

  test "should update email_rule" do
    patch email_rule_url(@email_rule), params: { email_rule: { copy_team: @email_rule.copy_team, email_template_id: @email_rule.email_template_id, klass_id: @email_rule.klass_id, state: @email_rule.state } }
    assert_redirected_to email_rule_url(@email_rule)
  end

  test "should destroy email_rule" do
    assert_difference('EmailRule.count', -1) do
      delete email_rule_url(@email_rule)
    end

    assert_redirected_to email_rules_url
  end
end
