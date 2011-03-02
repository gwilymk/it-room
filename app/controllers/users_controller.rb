class UsersController < ApplicationController
  before_filter :auth5, :except => [:update, :edit, :update_language, :forgotten_password, :update_password]
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

    if params[:user][:password]
      if User.authenticate(@user.username, params[:user][:old_password])
        if @user.update_attributes(params[:user])
          flash[:notice] = 'user.update'
        else
          flash[:notice] = notranslate error_messages @user
        end
      else
        @user.errors.add(:old_password, I18n.t('activerecord.errors.messages.old_password_incorrect'))
        flash[:notice] = notranslate error_messages @user
      end
    else
      if @user.update_attributes(params[:user])
        flash[:notice] = 'user.update'
      else
        flash[:notice] = notranslate error_messages @user
      end
    end

    redirect_to :controller => 'admin', :action => 'preferences'
  end

  def destroy
    @user = User.find(params[:id])
    if params[:id].to_i == session[:user_id].to_i
      flash[:notice] = notranslate 'Cannot delete own user'
      redirect_to :action => 'index'
      return
    end
    @user.destroy

    flash[:notice] = notranslate 'User was deleted'
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

  def search
    @users = User.where("username LIKE ? OR name LIKE ?", "%" + params[:query] + "%", "%" + params[:query] + "%").order("username")
    render :action => 'index'
  end

  def forgotten_password
    if request.post?
      @user = User.find_by_username(params[:username])
      unless @user
        flash[:notice] = 'admin.login.username_does_not_exist'
        redirect_to admin_login_path
        return
      end

      @key = @user.generate_forgotten_password_key

      puts @key

      begin
        Notifier.password_notification(@user, @key).deliver
      rescue
        puts "Failed to send password"
      end

      flash[:notice] = 'admin.login.sent_forgotten_password_message'
      redirect_to root_path
    end
  end

  def update_password
    return unless params[:key]

    if @user = User.find_by_forgotten_password_key(params[:key])
      if @user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
        flash[:notice] = 'admin.login.reset_password'
        @user.forgotten_password_key = nil
        @user.save
        redirect_to root_path
      else
        flash[:notice] = 'errors.error'
        render :action => 'forgotten_password'
      end
    end
  end
end

