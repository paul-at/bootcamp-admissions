require 'test_helper'

class AppFormsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @app_form = app_forms(:one)
    @klass = klasses(:one)
  end

  test "should get index" do
    get app_forms_url
    assert_response :success
  end

  test "should get new" do
    get new_app_form_url
    assert_response :success
  end

  test "should create app_form" do
    assert_difference('AppForm.count') do
      post app_forms_url, params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence } }
    end

    assert_response :success
  end

  test "should store answers to arbitrary question" do
    assert_difference("Answer.where(question: 'q', answer: 'a').count") do
      post app_forms_url, params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence,
      answers: { q: 'a' } } }
    end

    assert_response :success
  end

  test "should show app_form" do
    get app_form_url(@app_form)
    assert_response :success
  end

  test "should update app_form" do
    patch app_form_url(@app_form), params: { app_form: { klass_id: @klass.id, country: @app_form.country, dob: @app_form.dob, email: @app_form.email, firstname: @app_form.firstname, gender: @app_form.gender, lastname: @app_form.lastname, referral: @app_form.referral, residence: @app_form.residence } }
    assert_redirected_to app_form_url(@app_form)
  end
end
