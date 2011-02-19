class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_filter :localize
  before_filter :get_bookings

  protect_from_forgery

  protected

  def localize
    if session[:user_id]
      user = User.find session[:user_id]
      session[:locale] = user.prefered_language
    end

    session[:locale] = params[:locale] if params[:locale] # params overrights user
    I18n.locale = session[:locale]
  end

  def get_bookings
  	if session[:user_id]
  		@bookings_today = Booking.where(:user_id => session[:user_id], :date => Date.today).order(:lesson_number)
  	end
  end

  def authorize_user access
    user = User.find_by_id(session[:user_id])

    if user && user.access_level < access
      flash[:notice] = 'application.authorize.not_authorized'
      redirect_to :controller => 'admin', :action => 'login'
      return false
    end

    unless user
      flash[:message] = 'application.authorize.login'
      redirect_to :controller => 'admin', :action => 'login'
      return false
    end
  end

  def auth1
    authorize_user 1
  end

  def auth3
    authorize_user 3
  end

  def auth5
    authorize_user 5
  end
end

