require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV['API_KEY'] = 'test'
    @app_form = app_forms(:one)
    @app_form_two = app_forms(:two)
    @app_form_three = app_forms(:three)
  end

  test "should not allow to access API without correct key" do
    get '/api/v1/user/' + @app_form.email
    assert_response 401
  end

  test "should return missing response for applicant that has not applied" do
    get '/api/v1/user/non@existent.com?key=' + ENV['API_KEY']
    assert_response :missing
  end

  test "should return user response with correct syntax" do
    # all app forms are for same email
    assert_equal @app_form.email, @app_form_two.email
    # @app_form and @app_form_two are different subjects
    refute_equal @app_form.klass.subject_id, @app_form_two.klass.subject_id
    refute_equal @app_form.klass_id, @app_form_two.klass_id
    # @app_form_three and @app_form_two are same subjects different classes
    assert_equal @app_form_three.klass.subject_id, @app_form_two.klass.subject_id
    refute_equal @app_form_three.klass_id, @app_form_two.klass_id

    get '/api/v1/user/' + @app_form.email + '?key=' + ENV['API_KEY']
    assert_response :success
    assert_equal({
      user: @app_form.email,
      bootcamps: [
        {
          bootcamp_id: @app_form.klass.subject_id,
          bootcamp_title: @app_form.klass.subject.title,
          klasses: [
            {
              klasse_id: @app_form.klass_id,
              klasse_name: @app_form.klass.title,
              status: @app_form.aasm_state,
              is_user_eligible_to_pay: false,
            },
          ],
        },
        {
          bootcamp_id: @app_form_two.klass.subject_id,
          bootcamp_title: @app_form_two.klass.subject.title,
          klasses: [
            {
              klasse_id: @app_form_two.klass_id,
              klasse_name: @app_form_two.klass.title,
              status: @app_form_two.aasm_state,
              is_user_eligible_to_pay: false,
            },
            {
              klasse_id: @app_form_three.klass_id,
              klasse_name: @app_form_three.klass.title,
              status: @app_form_three.aasm_state,
              is_user_eligible_to_pay: true,
            },
          ],
        },
      ]
    }, JSON.parse(response.body, symbolize_names: true))
  end
end