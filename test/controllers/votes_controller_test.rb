require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @vote = votes(:one)
  end

  test "should get index" do
    sign_in @vote.user
    get app_form_votes_url(app_form_id: @vote.app_form_id), as: :json
    assert_response :success
  end

  test "should create vote" do
    sign_in @vote.user
    assert_difference('Vote.count') do
      post app_form_votes_url(app_form_id: @vote.app_form_id), params: { vote: { app_form_id: @vote.app_form_id, user_id: @vote.user_id, vote: @vote.vote } }
    end

    assert_response :success
  end

  test "should destroy vote" do
    sign_in @vote.user
    assert_difference('Vote.count', -1) do
      delete app_form_votes_url(app_form_id: @vote.app_form_id)
    end

    assert_response :success
  end
end
