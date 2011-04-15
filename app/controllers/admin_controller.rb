#
# This controller allows for many miscellaneous things such as logging in, autobooking
# and preferences.
#
class AdminController < ApplicationController
  # This forces the user to have authenticated themselves before they access crtitical components
  # to the system.
  before_filter :auth1, :only => ['logout', 'preferences']
  before_filter :auth3, :only => ['change_week', 'change_end_term', 'auto_book']

  # As the name suggests, it is called when the user logs in
  #
  # If the request is a post request, then the user has entered their username and
  # password in the login field. This means they expect the system to log them on
  #
  # If the request wasn't a post or they failed to login, the default
  # view will be rendered.
  def login
    if request.post?
      # Authenticate the user from the entered username and password
      if user = User.authenticate(params[:username], params[:password])
        # set the session to show they have logged in and who is logged in
        session[:user_id] = user.id

        # Tell the user in a dialog that they have logged in
        flash[:notice] = 'admin.login.successful'
        # Redirect to the root path
        redirect_to root_path
      else
        # Tell them that their login wasn't successful
        flash.now[:notice] = 'admin.login.unsuccessful'
      end
    end
  end

  # When called, the current user is logged out and the user_id in the session
  # is set to nil
  def logout
    # delete their user_id from the session
    session[:user_id] = nil
    # tell them the logout was successful
    flash[:notice] = 'admin.logout'

    # redirect them to the root url
    redirect_to root_path
  end

  # This action allows the user to change the information the system is holding
  # about them. This includes the name and their password. However, for security
  # reasons, the user cannot change their access level.
  def preferences
    # Find the current user
    @user = User.find(session[:user_id])
  end

  # This is a complex procedure which makes it possible for a user of admin status
  # or above to book every lesson of every day of every week _n_ to be fully booked.
  # This will mainly be used to automatically book all the the IT lessons or cross-
  # curricular lessons for every lesson in the given IT room.
  #
  # If the request was a post request, the user expects the system to do something,
  # if it is a get request, then the user expects the system to return a web page.
  def auto_book
    if request.post?
      # Starts the messae with an unordered list
      @message = "<ul>"

      # starts autobooking from today
      date = Date.today
      # create an empty booking
      @booking = Booking.new
      # sets the user_id to the one requested
      @booking.user_id = params[:user]
      # sets the room_id to the one requested
      @booking.room_id = params[:room]
      # sets the lesson number to the one requested
      @booking.lesson_number = params[:lesson_number]

      # sets the number of computers to the number in the room requested
      if params[:fully_book]
        @booking.number_of_computers = Room.find(params[:room]).number_of_computers
      else
        @booking.number_of_computers = params[:number_of_computers]
      end

      # caches the last day of the last term
      last_day = TermDate.last_term.term_end.to_date

      # until the end of the last term
      while date <= last_day
        # if that day is the one wanted
        if TermDate.week(date) == params[:week].to_i && date.wday == params[:day].to_i
          # duplicate the booking
          booking = @booking.dup
          # set the booking's date the the current one
          booking.date = date
          # adds a very informative list item to the message
          @message << "<li>" + I18n.t('booking.auto_book.made', :time => "#{date.strftime('%d/%m/%Y')}") + "</li>" if booking.save
        end

        # set the search date to the day after
        date += 1.day
      end

      # finish the unordered list
      @message << "</ul>"
      # tell rails that the string is safe
      @message.html_safe
    end
  end
end

