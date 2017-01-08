require 'test_helper'

class ImportControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess

  test "should assign Klass default PaymentTier to AppForms" do
    sign_in users(:admin)

    klass = klasses(:one)

    # verify that the fixtures have payment tier defined for the class we use
    assert_not_nil klass.payment_tier_id

    assert_difference('AppForm.count') do
      post import_import_path, params: {
        commit: 'Import',
        klass_id: klass.id,
        csv: fixture_file_upload('files/import.csv', 'text/csv')
      }
      assert_response :success
      assert_select 'div.alert', 0
    end

    assert_equal klass.payment_tier_id, AppForm.last.payment_tier_id
  end

  test "should update existing record" do
    sign_in users(:admin)

    klass = klasses(:one)
    app_form = klass.app_forms.where(email:'john@doe.com').take
    unless app_form
      app_form = AppForm.create!(firstname: 'a', lastname: 'b', email: 'john@doe.com', klass:klass)
      Answer.create!(app_form: app_form, question: 'question', answer: 'wrong answer')
    end

    post import_import_path, params: {
      commit: 'Update',
      klass_id: klass.id,
      csv: fixture_file_upload('files/import.csv', 'text/csv')
    }
    assert_response :success
    assert_select 'div.alert', 0
    assert_equal 'answer', Answer.where(question: 'question', app_form_id: app_form.id).take.answer
  end
end
