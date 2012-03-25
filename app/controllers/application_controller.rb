require 'searchlogic'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_timezone

  before_filter :create_brain_buster

  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def search
    if params[:search] && (params[:search].is_a? String)

    @users = User.login_like_or_bio_like_or_career_like_or_name_like_or_education_like(params[:search].downcase)
    @users = (@users.concat(User.has_tags(params[:search])).uniq).sort{ |a, b| a.login.downcase <=> b.login.downcase }.paginate(:page => params[:user_page], :per_page => 15)
    @posts = Post.title_like_or_content_like_or_poster_login_like_or_poster_name_like(params[:search].downcase)
    @posts = @posts.concat(Post.has_tags(params[:search])).uniq.sort{ |a, b| b.created_at <=> a.created_at }.paginate(:page => params[:post_page], :per_page => 5)
    elsif params[:search]
      @pagetitle = "search results"
      prms = params[:search]
      prms = prms.delete_if{ |k, v| v == 'any' }
      @prms = prms.to_s
      if params[:kind] == 'user'
        @search = User.search(prms)
        if params[:location].blank?
          @users = @search.paginate(:page => params[:page])
        else
          begin
            @nearbyusers = User.find(:all, :origin => params[:location], :order => 'distance', :within => 50)
          rescue
            @nearbyusers = []
          end
          @users = @users & @nearbyusers
          if @users
            @users = @users.paginate(:per_page => 10, :page => params[:page])
          else
            @users = []
          end
        end
        render 'users/index'
      else
        @posts = Post.search(params[:search]).paginate(:page => params[:page])
        render 'posts/index'
      end
    else
      @user_search = User.search
      if params[:mentors]
        @user_search.mentors = true
      end
      @post_search= Post.search
    end
  end

  def set_timezone
    if logged_in? && current_user.time_zone
      Time.zone = current_user.time_zone
    end
  end

  def index
    @posts = Post.find_all_by_front_page(true)
    @posts = @posts.sort{ |a, b| b.published_at <=> a.published_at }.paginate(:per_page => 5, :page => params[:page])
    @newestusers = User.find(:all).sort{ |a, b| b.created_at <=> a.created_at }.first(6)
    @activeusers = User.find(:all).sort{ |a, b| b.activity_level <=> a.activity_level }.first(6)
    User.send_later(:update_activity_levels)
    @user = User.new
    @comments = Comment.find(:all).sort{ |a, b| b.created_at <=> a.created_at }.first(3)
    @mentors = Array.new
    while @mentors.size < 3 
        @mentoring = Tag.find_all_by_object_type('User').sort_by{ rand }.first.name
        @mentors = User.has_tags(@mentoring).find_all{ |u| u.mentoring }.sort_by{ rand }.first(3)
    end
    respond_to do |format|
      format.html do
      end
      format.atom do 
        @posts = @posts
        render :layout => false
      end
    end
  end

  def admin
    if logged_in? && current_user.admin?
      true
    else
      false
    end
  end

  def rescue_action_in_public_without_hoptoad(exception)
    #maybe gather up some data you'd want to put in your error page
    @title = "Sorry!"
    case exception
    when ActiveRecord::RecordNotFound
      render :template => 'pages/404', :status => "404"
    when ActiveRecord::RecordInvalid
      render :template => 'pages/404', :status => "404"
    when ActionController::RoutingError
      render :template => 'pages/404', :status => "404"
    when ActionController::UnknownController
      render :template => 'pages/404', :status => "404"
    when ActionController::UnknownAction
      render :template => 'pages/404', :status => "404"
    when ActionController::MethodNotAllowed
      render :template => 'pages/404', :status => "404"
    else
      render :template => 'pages/500', :status => "500"
    end             
  end
  
  def render_or_redirect_for_captcha_failure
    render :action => 'index'
  end

end
