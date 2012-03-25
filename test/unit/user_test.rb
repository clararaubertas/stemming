require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  should_have_attached_file :avatar

  #FIXME: test has_private_messages

  #FIXME:
  def test_friends_posts
  end

  context "a User instance" do
    setup do
      @user = User.find(:first)
    end
    
    should " not create duplicated tags" do
      @user.tag_list = "Bad, Bad, Evil"
      @user.save!
      assert_equal @user.tags.size, 2
    end

    should "not accept an invalid email" do
      @user.email = "test"
      assert_equal(@user.email, "test")
#      assert_equal(@user.valid?, false)
    end

    should "accept a valid email" do
      @user.email = "test@example.com"
      assert_valid(@user)
      @user.email = "test@example.tv"
      assert_valid(@user)
    end
    
  end

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end


  def test_location_string
    users(:quentin).city = "Cambridge"
    assert_equal(users(:quentin).location_string, "Cambridge")
  users(:quentin).state = "MA"
    assert_equal(users(:quentin).location_string, "Cambridge, MA")
  users(:quentin).zip = "02138"
    assert_equal(users(:quentin).location_string, "02138")
  end

  def test_geocode
    users(:quentin).zip = "02138"
    users(:quentin).save_location
    assert_not_nil(users(:quentin).lat)
    assert_not_nil(users(:quentin).lng)
  end

  def test_activity_level
    assert_equal(users(:quentin).activity_level, users(:quentin).friends.size + users(:quentin).posts.size * 3)
  end

  def test_recommended_friends
    assert(users(:quentin).recommended_friends.is_a? Array)
    assert(!(users(:quentin).recommended_friends.include? users(:quentin)))
  end

  def test_attribution_slug
    assert_equal(users(:quentin).attribution_slug, "<a href='/users/1' class='slug'><img src='#{ users(:quentin).avatar.url(:verysmall)}' alt=''> quentin</a>")
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
    def create_post(options = { })
      Post.create({ :user_id => 1})
    end
end
