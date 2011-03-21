#
# The users controller is in charge of user admin. It does things such as creating,
# deleting and allowing the user to recover/change their password. The UsersController has
# a few actions which need authentication at different access_levels and even some
# which don't need authentication at all.
#
class UsersController < ApplicationController
  # some authentiaction filters, the details are in the action.
  before_filter :auth5, :except => [:update, :edit, :update_language, :forgotten_password, :update_password]
  before_filter :auth1, :only => [:update, :edit, :update_language]

  # Requires access_level >= 5. This ensures that only root users can view all the users
  # on the system
  def index
    @users = User.order('users.username')
  end

  # Requires access_level >= 5. This means only root users can create new user accounts
  def new
    @user = User.new
  end

  # Requires access_level >= 5. This action is rarly used and is dissapearing into obscurity
  # and deprication
  def edit
    @user = User.find(params[:id])
  end

  # Requires access_level >= 5. This action creates the user from the params specified
  def create
    # create the user wanted
    @user = User.new(params[:user])

    # if the user saves
    if @user.save
      # tell them that it did
      flash[:notice] = notranslate 'User was successfully created.'
      # and redirect to the index
      redirect_to :action => 'index'
    else
      # tell them it failed and the error messages
      flash[:notice] = notranslate error_messages(@user)
      # and redirect to the index
      redirect_to :action => 'index'
    end
  end

  # Required access_level >= 1. This can only be called for your own user and is in charge
  # of updating information about the user e.g. their password and name. This action cannot
  # be used to change access_level. This action is called from the view in AdminController#preferences
  def update
    # find the current user
    @user = User.find(session[:user_id])

    # if they want to change their password
    if params[:user][:password]
      # if the old password is correct
      if User.authenticate(@user.username, params[:user][:old_password])
        # if they change their password properly
        if @user.update_attributes(params[:user])
          # tell them it did
          flash[:notice] = 'user.update'
        else
          # otherwise, tell them why it didn't
          flash[:notice] = notranslate error_messages @user
        end
      else
        # tell them that the old password they entered is incorrect
        @user.errors.add(:old_password, I18n.t('activerecord.errors.messages.old_password_incorrect'))
        flash[:notice] = notranslate error_messages @user
      end
    else
      # if the other information entered is valid
      if @user.update_attributes(params[:user])
        # tell them that the user was updated
        flash[:notice] = 'user.update'
      else
        # else tell them why it failed
        flash[:notice] = notranslate error_messages @user
      end
    end

    # redirect back to the preferences
    redirect_to admin_preferences_path
  end

  # Requires access_level >= 5. This action destroys the user. There is a security measure
  # taken into account to make sure that there are always users on the system. This is
  # measure is done because if the last root user deletes their own user account, then
  # the system becomes unreachable and the only way to recreate users is by using the dbconsole.
  #
  # The destroy method makes sure that the user you are trying to delete isn't the one currently
  # logged in. This prevents any way for there to be no root users left.
  def destroy
    # find the User the user wants to delete
    @user = User.find(params[:id])

    # if it is the currently logged in user
    if params[:id].to_i == session[:user_id].to_i
      # give them a nice error message they can work with
      flash[:notice] = notranslate 'Cannot delete own user'
      # and redirect them back to the index
      redirect_to :action => 'index'
      # this return is *very* important. Without it, the code will happily keep runing and delete
      # the user anyway.
      return
    end

    # after all that checking, we can finally delete the user
    @user.destroy

    flash[:notice] = notranslate 'User was deleted'
    # redirect them back to the index
    redirect_to :action => 'index'
  end

  # Requires access_level >= 1. This is fairly self explantory as it takes the params
  # which give the prefered language. The prefered language is part of the information
  # stored in the users table. Although the parameters given override the information in
  # the users table, it still sets a default for the user to use. This can be very important
  # as it can get very annoying if everytime a person who wants the page in welsh has to
  # change it every time.
  def update_language
    # Find the currently logged in user
    user = User.find(session[:user_id])

    # set their prefered language to the one given
    user.prefered_language = params[:prefered_language]
    # and save it.
    user.save!

    # tell the user it worked
    flash[:notice] = 'language.changed'
    # and bring them to the homepage
    redirect_to root_path
  end

  # Requires access_level >= 5. This action is used to make sure that a root user can log in as
  # a given user without the need for a password. This can be misused and therefore requires root
  # permissions
  def log_in_as
    # set the current user_id to the one wanted
    session[:user_id] = params[:user_id]
    # and redirect them to the root_path as the new user
    redirect_to root_path
  end

  # Requires access_level >= 5. This action is used if there are too many users to search through manually.
  # The query uses a 'LIKE' statement which means that the information entered can be part or the whole name
  # wanted. This is generally what the user wants from a search facility.
  def search
    # the @users array is used in the index action
    @users = User.where("username LIKE ? OR name LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").order("username")
    # render the index action only showing the ones in the query
    render :action => 'index'
  end

  # Requires no user logged in. This is a RESTful call i.e. if the call was made with a 'get' request (e.g. the
  # user clicked on a hyperlink) it shows one thing and if the users gave it a 'post' request, then it will do
  # something else.
  #
  # If the request is a post request, the system will take the params given and use them to generate a
  # forgotten_password_key for them. This is stored in the users table for future access. The key is sent
  # to the user by email and then a link is also generated for them to use. This will make sure that the
  # user entered can only be them.
  #
  # If the request is a get request, this action will return a form in which the user can enter their new password.
  def forgotten_password
    if request.post?
      # find the username wanted
      @user = User.find_by_username(params[:username])
      # if the user doesn't exist
      unless @user
        # tell them it doesn't
        flash[:notice] = 'admin.login.username_does_not_exist'
        # and redirect them to the login path
        redirect_to admin_login_path
        return
      end

      # generate the forgotten_password_key for the user
      @key = @user.generate_forgotten_password_key

      begin
        # and send them an email with the password on it
        Notifier.password_notification(@user, @key).deliver
      rescue
        puts "Failed to send password"
      end

      # tell the user the email was sent
      flash[:notice] = 'admin.login.sent_forgotten_password_message'
      # and redirect to the root_path
      redirect_to root_path
    end
  end

  # Requires no user to be logged on. This action does the acctual changing of the password. The key
  # given is inputted and the action find the user with that key and changes their password accoringly.
  # This, ofcourse is done in such a way that the user must confirm their password choice
  def update_password
    # if the key parameter isn't given, don't do anything. This is very important as without this line
    # of code, the user will be able to change the password of any user by entering no key.
    return unless params[:key]

    # If the user with the forgotten password key is found
    if @user = User.find_by_forgotten_password_key(params[:key])
      # update the attributes with the ones given
      if @user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
        flash[:notice] = 'admin.login.reset_password'
        # set the forgotten password key back to nil
        @user.forgotten_password_key = nil
        # save again
        @user.save!

        # redirect the user back to the root_path
        redirect_to root_path
      else
        # else tell them that there was an error for setting the password incorrectly
        flash[:notice] = 'errors.error'
        render :action => 'forgotten_password'
      end
    end
  end
end

