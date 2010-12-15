class AdminController < ApplicationController
  before_filter :auth3, :only => ['change_week', 'change_end_term', 'auto_book']

  def login
    if request.post?
      user = User.authenticate(params[:username], params[:password])

      if user
        session[:user_id] = user.id

        puts "Logged in"
        flash[:notice] = 'Successfully logged in'
        redirect_to '/'
      else
        puts "Failed"
        flash.now[:notice] = 'Login failed'
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = 'Logged out'

    redirect_to '/'
  end

  def preferences
    @user = User.find(session[:user_id])
  end

  def change_week
    APP_CONFIG['week']['invert'] = !invert_week?
    save_config

    redirect_to '/'
  end

  def change_end_term
    if request.post?
      APP_CONFIG['term']['end'] = format_date(params['change_date']).to_date
      save_config

      redirect_to '/'
    else
      @current_end = term_end.to_date.strftime("%d/%m/%Y")
      puts @current_end
    end
  end

  def auto_book
    if request.post?
      message = '<ul>'

      date = Date.today
      @booking = Booking.new
      @booking.user_id = params[:user]
      @booking.room_id = params[:room]
      @booking.lesson_number = params[:lesson_number]

      @booking.number_of_computers = Room.find(params[:room]).number_of_computers

      while date <= term_end do
        if week(date) == params[:week].to_i && date.wday == params[:day].to_i
          @booking.date = date
          message << "<li>You made a booking on #{date.strftime('%A, %d %B %Y')}</li>"
          @booking.save
        end

        date = date.tomorrow
      end

      message << "</ul>"
      message.html_safe
      flash.now[:notice] = message
    end
  end
end

