#
# The standard controller which all controllers extend from. This means all
# method defined here will show up in all the other controllers
#
class ApplicationController < ActionController::Base
  # Make sure we get all of the application helper methods
  include ApplicationHelper

  # Set the locale depending on curtain conditions.
  before_filter :localize
  # get the bookings for the current user loggd on
  before_filter :get_bookings

  # Protect the system form forgery
  protect_from_forgery

  protected

  # Sets the locale to the one specified
  def localize
    # if the user is logged on
    if session[:user_id]
      # get the current user
      user = User.find session[:user_id]
      # find out what thier preffered locale is
      session[:locale] = user.prefered_language
    end

    # params overright user preferences
    session[:locale] = params[:locale] if params[:locale]
    # set the locale
    I18n.locale = session[:locale]
  end

  # Gets the bookings for the current user (if they are logged in) and sets
  # the variable _@bookings_today_ to the bookings.
  def get_bookings
    # if the user is logged on
  	if session[:user_id]
  	  # set the variable @bookings_today to the bookings where the user is the current logged on
  	  # user and the date is today. Also, this orders them by the lesson number for the convenience
  	  # of the user
  		@bookings_today = Booking.where(:user_id => session[:user_id], :date => Date.today).order(:lesson_number)
  	end
  end

  # This makes sure the user has an access level greater than _access_
  # This is mainly used internally as the main methods used as filters
  # are the methods auth1, auth3 and auth5
  def authorize_user access
    # finds the current user
    user = User.find_by_id(session[:user_id])

    # if the user is found and their access level is too low
    if user && user.access_level < access
      # Tell the user that they aren't authorised to access that URL
      flash[:notice] = 'application.authorize.not_authorized'
      # redirects them to the login path
      redirect_to admin_login_path
      # tells the system not to bother with the rest of the action
      return false
    end

    # if the user_id supplied doesn't exist or there is no current user
    unless user
      # tell the person they must login
      flash[:message] = 'application.authorize.login'
      # redirect to the login path
      redirect_to admin_login_path
      # and again, tell the system not to bother with the action
      return false
    end
  end

  # Makes sure the user is a teacher or above
  def auth1
    authorize_user 1
  end

  # Makes sure the user is an admin or above
  def auth3
    authorize_user 3
  end

  # Makes sure the user is a root or above
  def auth5
    authorize_user 5
  end
end

