class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :create_brain_buster, :only => ['signup']

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in?
  end

  def login
    return unless request.post?
    @title = "login"
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Sorry, that username/password was not found."
    end
  end

  def signup
    @user = User.new(params[:user])
    @title = "join the community of women and girls in STEM"
    unless session[:user_params].blank?
      @user = User.new(session[:user_params])
      @user.save!
    end
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

  def render_or_redirect_for_captcha_failure
    render :action => 'signup'
  end


end
