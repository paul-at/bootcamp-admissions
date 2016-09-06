require 'test_helper'

class KlassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @klass = klasses(:one)
    @klass_without_applications = klasses(:three)
  end

  test "should get index" do
    get klasses_url
    assert_response :success
  end

  test "should get new" do
    get new_klass_url
    assert_response :success
  end

  test "should create klass" do
    assert_difference('Klass.count') do
      post klasses_url, params: { klass: { archived: @klass.archived, deposit: @klass.deposit, subject_id: @klass.subject_id, title: @klass.title, tuition: @klass.tuition } }
    end

    assert_redirected_to klasses_url
  end

  test "should get edit" do
    get edit_klass_url(@klass)
    assert_response :success
  end

  test "should update klass" do
    patch klass_url(@klass), params: { klass: { archived: @klass.archived, deposit: @klass.deposit, subject_id: @klass.subject_id, title: @klass.title, tuition: @klass.tuition } }
    assert_redirected_to klasses_url
  end

  test "should destroy klass" do
    assert_difference('Klass.count', -1) do
      delete klass_url(@klass_without_applications)
    end

    assert_redirected_to klasses_url
  end
end
