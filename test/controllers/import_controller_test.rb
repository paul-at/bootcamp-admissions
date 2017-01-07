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
    end

    assert_equal klass.payment_tier_id, AppForm.last.payment_tier_id
  end
end
