class RequestsController < ApplicationController

  def hide_selected
    if request.post?
      if params[:mark_as_read]
        params[:mark_as_read].each { |id|
          @request = Request.find(id)
          @request.mark_as_read unless @request.nil?
        }
        flash[:notice] = "Requests hidden"
      end
      redirect_to :action => 'index'
    end
  end



  # GET /requests
  # GET /requests.xml
  def index
    @title = "your requests"
    if logged_in?
    @requests = Request.find_all_by_recipient_id_and_read(current_user.id, false)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requests }
    end
    else
      redirect_to :controller => 'account', :action => 'login'
    end

  end


  # GET /requests/new
  # GET /requests/new.xml
  def new
    @title = "new #{params[:request_type]} request"
    @request = Request.new
    @user = User.find(params[:user_id])
    if params[:request_type] == 'networking'
      @kind = "network with"
    elsif params[:request_type] == 'mentoring'
      @kind = "mentor"
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.xml
  def create
    @request = Request.new(params[:request])
    unless @request.message.blank?
      @request.message = "\n\n" + current_user.name.titleize + " says:\n" + @request.message
    end
    @email = "\nEmail #{current_user.pronoun('obj')} at #{current_user.email} so you can get together."
    if @request.request_type == 'menteeing'
      @request.message = current_user.name.titleize + " wants you to mentor " + current_user.pronoun('obj')+ "!" + @email + @request.message
    elsif @request.request_type == 'networking'
      @request.message = current_user.name.titleize + " wants to network with you!" + @email + @request.message
    elsif @request.request_type == 'mentoring'
      @request.message = current_user.name.titleize + " wants to mentor you!" + @email + @request.message
    end
    if @request.save
      UserNotifier.deliver_request(User.find(@request.recipient_id), current_user, @request)
      flash[:notice] = "Your request has been sent to " + User.find(@request.recipient_id).login
        redirect_to :action => 'show', :controller => 'users', :id => @request.recipient_id
      else
        flash[:notice] = "Sorry, something went wrong."
        redirect_to :action => 'show', :controller => 'users', :id => @request.recipient_id
      end
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    @request = Request.find(params[:id])

    respond_to do |format|
      if @request.update_attributes(params[:request])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.xml
  def destroy
    @request = Request.find(params[:id])
    @request.destroy

    respond_to do |format|
      format.html { redirect_to(requests_url) }
      format.xml  { head :ok }
    end
  end
end
