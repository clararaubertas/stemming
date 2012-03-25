require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should show users" do
    get :show, :id => tags(:two).to_param, :kind => "users"
  end

  test "should show posts" do
    get :show, :id => tags(:one).to_param, :kind => "posts"
  end

end
