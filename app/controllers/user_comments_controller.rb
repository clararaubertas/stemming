class UserCommentsController < ApplicationController
  # GET /user_comments
  # GET /user_comments.xml
  def index
    @user_comments = UserComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_comments }
    end
  end

  # GET /user_comments/1
  # GET /user_comments/1.xml
  def show
    @user_comment = UserComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_comment }
    end
  end

  # GET /user_comments/new
  # GET /user_comments/new.xml
  def new
    @user_comment = UserComment.new
    render :partial => 'new'
  end

  # GET /user_comments/1/edit
  def edit
    @user_comment = UserComment.find(params[:id])
    render :partial => 'edit'
  end

  # POST /user_comments
  # POST /user_comments.xml
  def create
    @user_comment = UserComment.new(params[:user_comment])
    
    if @user_comment.save
      flash[:notice] = 'Your comment was added.'
      UserNotifier.deliver_comment(@user_comment.commentable, @user_comment.user)
    end
    redirect_to user_url(@user_comment.commentable)
  end

  # PUT /user_comments/1
  # PUT /user_comments/1.xml
  def update
    @user_comment = UserComment.find(params[:id])

      if @user_comment.update_attributes(params[:user_comment])
        flash[:notice] = 'Your comment was successfully updated.'
      end
    redirect_to user_url(@user_comment.user)
  end

  # DELETE /user_comments/1
  # DELETE /user_comments/1.xml
  def destroy
    @user_comment = UserComment.find(params[:id])
    @user = @user_comment.user
    @user_comment.destroy
    flash[:notice] = "Your comment was deleted."
    redirect_to user_url(@user)

  end
end
