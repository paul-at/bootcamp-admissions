require 'test_helper'

class AppFormsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @app_form = app_forms(:one)
    @klass = klasses(:one)
  end

  test "should get index" do
    sign_in users(:staff)

    get app_forms_url, params: { search: AppForm.searches.keys.first, klass_id: @klass.id }
    assert_response :success
  end

  test "should get new" do
    get new_app_form_url
    assert_response :success
  end

  test "should create app_form" do
    assert_difference('AppForm.count') do
      post app_forms_url, params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence, city: @app_form.city } }
    end

    assert_response :success
  end

  test "should store answers to arbitrary question" do
    assert_difference("Answer.where(question: 'q', answer: 'a').count") do
      post app_forms_url, params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence, city: @app_form.city,
      answers: { q: 'a' } } }
    end

    assert_response :success
  end

  test "should apply default payment tier to new applications" do
    post app_forms_url, params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence, city: @app_form.city } }

    assert_equal @klass.payment_tier_id, AppForm.last.payment_tier_id
  end

  test "should show app_form" do
    sign_in users(:staff)
  
    get app_form_url(@app_form)
    assert_response :success
  end

  test "should update app_form" do
    sign_in users(:staff)

    patch app_form_url(@app_form), params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence, city: @app_form.city } }
    assert_redirected_to app_form_url(@app_form)
  end
end
