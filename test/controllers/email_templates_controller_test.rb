require 'test_helper'

class EmailTemplatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @email_template = email_templates(:one)
    @unreferenced_email_template = email_templates(:two)
  end

  test "should get index" do
    get email_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_email_template_url
    assert_response :success
  end

  test "should create email_template" do
    assert_difference('EmailTemplate.count') do
      post email_templates_url, params: { email_template: { body: @email_template.body, subject: @email_template.subject, title: @email_template.title } }
    end

    assert_redirected_to email_template_url(EmailTemplate.last)
  end

  test "should show email_template" do
    get email_template_url(@email_template)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_template_url(@email_template)
    assert_response :success
  end

  test "should update email_template" do
    patch email_template_url(@email_template), params: { email_template: { body: @email_template.body, subject: @email_template.subject, title: @email_template.title } }
    assert_redirected_to email_template_url(@email_template)
  end

  test "should destroy email_template that is not referenced" do
    post email_templates_url, params: { email_template: { body: @unreferenced_email_template.body, subject: @unreferenced_email_template.subject, title: @unreferenced_email_template.title } }
    assert_difference('EmailTemplate.count', -1) do
      delete email_template_url(@unreferenced_email_template)
    end

    assert_redirected_to email_templates_url
  end

  test "should not destroy email_template that is referenced in rules" do
    assert_raises ActiveRecord::InvalidForeignKey do
      delete email_template_url(@email_template)
    end
  end
end
