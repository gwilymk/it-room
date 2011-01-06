class UsersController < ApplicationController
  before_filter :auth5, :except => [:update, :edit, :update_language]
  before_filter :auth1, :only => [:update, :edit, :update_language]

  def index
    @users = User.order('users.username')
  end

  def new
    @user = User.new

    respond_to do |format|
      format.js
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = ("NO TRANSLATE" + 'User was successfully created.')
      redirect_to :action => 'index'
    else
      flash[:notice] = ("NO TRANSLATE" + error_messages(@user))
      redirect_to :action => 'index'
    end
  end

  def update
    @user = User.find(session[:user_id])

    if @user.update_attributes(params[:user])
      flash[:notice] = 'user.update'
    else
      flash[:notice] = error_messages @user
    end

    redirect_to :controller => 'admin', :action => 'preferences'
  end

  def destroy
    @user = User.find(params[:id])
    if params[:id] == session[:user_id]
      flash[:notice] = ("NO TRANSLATE" + 'Cannot delete own user')
      redirect_to :action => 'index'
    end
    @user.destroy

    flash[:notice] = ("NO TRANSLATE" + 'User was deleted')
    redirect_to :action => 'index'
  end

  def update_language
    user = User.find(session[:user_id])

    user.prefered_language = params[:prefered_language]
    user.save!

    flash[:notice] = 'language.changed'
    redirect_to '/'
  end

  def log_in_as
    session[:user_id] = params[:user_id]
    redirect_to '/'
  end
end

