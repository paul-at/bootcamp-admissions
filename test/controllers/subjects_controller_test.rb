require 'test_helper'

class SubjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @subject = subjects(:one)
  end

  test "should get index" do
    sign_in users(:admin)

    get subjects_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:admin)

    get new_subject_url
    assert_response :success
  end

  test "should create subject" do
    sign_in users(:admin)

    assert_difference('Subject.count') do
      post subjects_url, params: { subject: { title: @subject.title } }
    end

    assert_redirected_to subjects_url
  end
  
  test "should get edit" do
    sign_in users(:admin)

    get edit_subject_url(@subject)
    assert_response :success
  end

  test "should update subject" do
    sign_in users(:admin)

    patch subject_url(@subject), params: { subject: { title: @subject.title } }
    assert_redirected_to subjects_url
  end
end
