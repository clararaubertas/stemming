class PagesController < ApplicationController

  def show
    @title = params[:page]
    render :action => params[:page]
  end

end
