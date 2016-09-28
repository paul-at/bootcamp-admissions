require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @admin = users(:admin)
    @staff = users(:staff)
    @new = users(:one)
  end

  test "should allow staff access to dashboard" do
    sign_in @staff

    get :index

    refute_includes assigns(:klasses), klasses(:one)
    assert_includes assigns(:klasses), klasses(:two)
    assert_response :success
  end

  test "should allow admin access to dashboard" do
    sign_in @admin
    
    get :index
    assert_response :success
  end

  test "should not allow freshly registered user access" do
    sign_in @new
    
    get :index
    assert_response :redirect
  end
end