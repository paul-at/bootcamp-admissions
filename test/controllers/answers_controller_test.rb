require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @answer = answers(:one)
  end

  test "should get index" do
    @app_form = app_forms(:one)
    get app_form_answers_url(@app_form)
    assert_response :success
  end
end
