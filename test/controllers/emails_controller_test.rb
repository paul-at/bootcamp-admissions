require 'test_helper'

class EmailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @email = emails(:one)
    sign_in users(:admin)
  end

  test "should get index" do
    get emails_url
    assert_response :success
  end

  test "should get new" do
    get new_email_url
    assert_response :success
  end

  test "should create email" do
    assert_difference('Email.count') do
      post emails_url, params: { app_form_ids: [app_forms(:one).id], email: { body: @email.body, copy_team: @email.copy_team, subject: @email.subject } }
    end

    assert_redirected_to emails_url
  end

  test "should show email" do
    get email_url(@email)
    assert_response :success
  end
end
