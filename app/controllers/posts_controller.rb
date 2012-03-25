class PostsController < ApplicationController

  include Bloget::Controllers::PostsController 
  before_filter :admin, :only => [:make_front_page, :unmake_front_page]


  def tag_suggestions
    @tags = Tag.find(:all, :conditions => ["object_type LIKE 'Post' AND name LIKE ?", "%#{ params[:post][:tag_list]}%"])
    render :layout => false
  end


  def search
    if params[:search]
      @posts = Post.search(params[:search]).paginate(:page => params[:page])
      @tags = Post.tag_counts.sort{ |x, y| x.name <=> y.name } 

      @title = "search results"
      render :action => 'index'
    else
      @search = Post.search
      @title = "search posts"
    end
  end

  def destroy
    if (current_user == @post.poster) && (@post.destroy_comments && @post.destroy)
          flash[:notice] = "Your post has been successfully deleted."
        else
          flash[:error] = "There was some problem deleting your post."
    end
        redirect_to posts_url

  end


  def make_front_page
    @post = Post.find_by_id(params[:id])
    @post.front_page = true
    @post.save
    flash[:notice] = "This post has been successfully featured."
    redirect_to :action => 'show', :controller => 'posts', :id => @post
  end

  def unmake_front_page
    @post = Post.find_by_id(params[:id])
    @post.front_page = false
    @post.save
    flash[:notice] = "This post is no longer featured."
    redirect_to :action => 'show', :controller => 'posts', :id => @post
  end


end
