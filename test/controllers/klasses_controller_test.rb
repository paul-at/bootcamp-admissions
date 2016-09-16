require 'test_helper'

class KlassesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @klass = klasses(:one)
    @klass_without_applications = klasses(:three)
  end

  test "should get index" do
    sign_in users(:admin)

    get klasses_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:admin)

    get new_klass_url
    assert_response :success
  end

  test "should create klass" do
    sign_in users(:admin)

    assert_difference('Klass.count') do
      post klasses_url, params: { klass: { archived: @klass.archived, subject_id: @klass.subject_id, title: @klass.title } }
    end

    assert_redirected_to klasses_url
  end

  test "should get edit" do
    sign_in users(:admin)

    get edit_klass_url(@klass)
    assert_response :success
  end

  test "should update klass" do
    sign_in users(:admin)

    patch klass_url(@klass), params: { klass: { archived: @klass.archived, subject_id: @klass.subject_id, title: @klass.title } }
    assert_redirected_to klasses_url
  end

  test "should destroy klass" do
    sign_in users(:admin)
    
    assert_difference('Klass.count', -1) do
      delete klass_url(@klass_without_applications)
    end

    assert_redirected_to klasses_url
  end
end
