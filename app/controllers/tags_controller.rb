class TagsController < ApplicationController

  def index
    if params[:least]
      @least = params[:least]
    else
      @least = 3
    end
    if params[:kind] == 'users'
      @tags = User.tag_counts(:at_least => @least).sort { |x, y| x.name <=> y.name }
      @title = "browse users by tag in the community for women in science/tech/engineering/math"

    elsif params[:kind] == 'posts'
      @tags = Post.tag_counts(:at_least => @least).sort { |x, y| x.name <=> y.name }
      @title = "browse blog posts by tag in the community for women in science/tech/engineering/math"

    end
  end

  def redirect
    redirect_to :action => 'show', :obj_type => 'posts', :name => params[:link], :status => 301
  end
  
  def show
    @object_type = params[:obj_type].gsub(/s$/, '').titleize
    @tag = Tag.find_by_name_and_object_type(params[:name].downcase, @object_type)
    if @tag.nil?
      raise ActiveRecord::RecordNotFound
    end
    @title = @tag.name.downcase + ' ' + @object_type.downcase + 's'
    if @object_type == 'Post'
      @posts = Post.find_tagged_with(@tag).find_all{ |p| p.published_at}.sort{ |a, b| b.published_at <=> a.published_at }.paginate(:per_page => 10, :page => params[:page])
      @pagetitle = "posts tagged with #{@tag.name}"
      render "posts/index"
    elsif @object_type == 'User'

      @users = User.find_tagged_with(@tag).sort{ |x, y| x.login.downcase <=> y.login.downcase }.paginate(:per_page => 10, :page => params[:page])
      @pagetitle = "users interested in #{@tag.name}"
      render "users/index"
    end

  end


end
