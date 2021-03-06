class UsersController < ApplicationController

  before_filter :validate_brain_buster, :only => [:create]
  after_filter :pagetitle

  def new
    @user = User.new
  end

  def invite
    if params[:token]
      gmail = Contacts::Google.new(params[:token])
      @contacts = gmail.contacts
    elsif request.post?
      for r in params[:recipients].split(',')
        UserNotifier.deliver_invitation(params[:message], r)
      end
      flash[:notice] = "Your message has been emailed to your friends! Hopefully you'll see them on Stemming soon."
    end
  end
  
  def render_or_redirect_for_captcha_failure
    @user = User.new(params[:user])
    render :template => 'account/signup'
  end

  def tag_suggestions
    @tags = Tag.find(:all, :conditions => ["object_type LIKE 'User' AND name LIKE ?", "%#{ params[:user][:tag_list]}%"])
  render :layout => false
  end


  def forgot_password
    return unless request.post?
    @title = "reset your password"
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "A password reset link has been sent to your email address"
    else
      flash[:notice] = "Could not find a user with that email address"
    end
  end

  
  def reset_password
    password_reset_code = request.post? ? params[:password_reset_code] : params[:id]
    return if password_reset_code.blank?
    @title = "reset your password"
    if @user = User.find_by_password_reset_code(password_reset_code)
      self.current_user = @user
      redirect_to(:action => 'change_password')
    else
      logger.error "Invalid Password Reset Code entered." 
      flash[:notice] = "Invalid Password Reset Code entered. Please check your Code and try again." 
    end
  end

  def change_password
    return unless request.post?
    @title = "change your password"
    if (params[:password] == params[:password_confirmation])
      current_user.password_confirmation = params[:password_confirmation]
      current_user.password = params[:password]
      current_user.reset_password
      current_user.save
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
      redirect_back_or_default(:action => 'index')
    else
      flash[:notice] = "Password mismatch" 
    end  
  end



  def search
    if params[:search]
      @pagetitle = "search results"
      prms = params[:search]
      prms = prms.delete_if{ |k, v| v == 'any' }
      @prms = prms.to_s
      @search = User.search(prms)
      if params[:location].blank?
        @users = @search.paginate(:page => params[:page])
      else
        @users = @search.all.sort_by_distance_from(params[:location])
        @users = @users.paginate(:per_page => 10, :page => params[:page])
      end
      render :action => 'index'
    else
      @title = "search users"
      @search = User.search
    end
  end

  def request_friendship
    @friend = User.find(params[:id])
    current_user.request_friendship_with(@friend)
    UserNotifier.deliver_friend_request(current_user, @friend)
    flash[:notice] = "You've sent a friend request to " + @friend.login
    redirect_to :action => 'show', :id => params[:id]
  end

  def accept_friendship
    current_user.accept_friendship_with(User.find(params[:id]))
    flash[:notice] = "You are now friends with " + User.find(params[:id]).login + '.'
    redirect_to :action => 'show', :id => User.find(params[:id])
  end

  def decline_friendship
    current_user.delete_friendship_with(User.find(params[:id]))
    flash[:notice] = "You have declined a friend request from " + User.find(params[:id]).login + '.'
    redirect_to :action => 'show', :id => User.find(params[:id])
  end


  def cancel_friendship
    current_user.delete_friendship_with(User.find(params[:id]))
    flash[:notice] = "You are no longer friends with " + User.find(params[:id]).login + '.'
    redirect_to :action => 'show', :id => params[:id]
  end


  # GET /users
  # GET /users.xml
  def index
    @title = "all users in the community for women in science/tech/engineering/math"
    @pagetitle = "all users"
    @users = User.paginate(:page => params[:page], :order => "created_at DESC", :per_page => 60)
    @newestusers = User.find(:all).sort{ |a, b| b.created_at <=> a.created_at }.first(4)
    @activeusers = User.find(:all).sort{ |a, b| b.activity_level <=> a.activity_level }.first(8)
    @mentors = Array.new
    while @mentors.size < 4 
      @mentoring = ["anthropology", "astronomy", "astrophysics", "biology", "computer science", "geology", "mathematics", "open-source software", "physics", "psychology", "programming", "chemistry", "science", "linux", "ecology", "math", "maths"].sort_by{ rand }.first
      @mentors = User.has_tags(@mentoring).find_all{ |u| u.mentoring }.sort_by{ rand }.first(4)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(:first, :conditions => ["LOWER(login) LIKE ?", params[:id].downcase])
    if @user.nil?
      raise ActiveRecord::RecordNotFound
    end
    @title = "#{@user.login}'s profile"
    @friends = @user.friends.sort_by{ |f| f.login.downcase }.paginate(:per_page => 24, :page => params[:friend_page])
    @blog_entries = @user.posts.find_all{ |p| p.published }.sort{ |a, b| b.published_at <=> a.published_at }.paginate(:per_page => 3, :page => params[:blog_page])
    @comments = @user.user_comments.reverse.paginate(:per_page => 3, :page => params[:comment_page])
    @blog_comments = @user.comments.reverse.paginate(:per_page => 3, :page => params[:blog_comment_page])
    unless @user == current_user
      @mentoring_request = Request.find_by_user_id_and_recipient_id_and_request_type(current_user.id, @user.id, "mentoring")
      @menteeing_request = Request.find_by_user_id_and_recipient_id_and_request_type(current_user.id, @user.id, "menteeing")
      @networking_request = Request.find_by_user_id_and_recipient_id_and_request_type(current_user.id, @user.id, "networking")
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
    @title = "edit your profile"
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.profile_updated_at = Time.now
      if @user.save
        self.current_user = @user
        flash[:notice] = 'User was successfully created.'
        redirect_to(@user)
      else
        session[:user_params] = params[:user]
        redirect_to :action => 'new', :controller => 'users'
      end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update

    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.profile_updated_at = Time.now
        @user.save
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to :action => 'show', :controller => 'users', :id => @user }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    for c in Comment.find_all_by_poster_id(@user.id)
      c.destroy
    end
    for f in Friendship.find_all_by_user_id(@user.id)
      f.destroy
    end
    for f in Friendship.find_all_by_friend_id(@user.id)
      f.destroy
    end
    for p in Post.find_all_by_poster_id(@user.id)
      p.destroy
    end
    for r in Request.find_all_by_user_id(@user.id)
      r.destroy
    end
    for r in Request.find_all_by_recipient_id(@user.id)
      r.destroy
    end
    for m in @user.received_messages
      m.destroy
    end
    for m in @user.sent_messages
      m.destroy
    end
    UserNotifier.deliver_deletion_message(@user)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def pagetitle
    @pagetitle = @title
  end

end
