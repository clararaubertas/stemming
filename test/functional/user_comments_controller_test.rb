require 'test_helper'

class UserCommentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_comment" do
    assert_difference('UserComment.count') do
      post :create, :user_comment => { }
    end

    assert_redirected_to user_comment_path(assigns(:user_comment))
  end

  test "should show user_comment" do
    get :show, :id => user_comments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_comments(:one).to_param
    assert_response :success
  end

  test "should update user_comment" do
    put :update, :id => user_comments(:one).to_param, :user_comment => { }
    assert_redirected_to user_comment_path(assigns(:user_comment))
  end

  test "should destroy user_comment" do
    assert_difference('UserComment.count', -1) do
      delete :destroy, :id => user_comments(:one).to_param
    end

    assert_redirected_to user_comments_path
  end
end
