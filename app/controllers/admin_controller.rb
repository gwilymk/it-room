class AdminController < ApplicationController
  before_filter :auth3, :only => ['change_week', 'change_end_term', 'auto_book']

  def login
    if request.post?
      user = User.authenticate(params[:username], params[:password])

      if user
        session[:user_id] = user.id

        puts "Logged in"
        flash[:notice] = 'admin.login.successful'
        redirect_to '/'
      else
        puts "Failed"
        flash.now[:notice] = 'admin.login.unsuccessful'
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = 'admin.logout'

    redirect_to '/'
  end

  def preferences
    @user = User.find(session[:user_id])
  end

  def auto_book
    if request.post?
      @message = "<ul>"

      date = Date.today
      @booking = Booking.new
      @booking.user_id = params[:user]
      @booking.room_id = params[:room]
      @booking.lesson_number = params[:lesson_number]

      @booking.number_of_computers = Room.find(params[:room]).number_of_computers

      last_day = TermDate.last_term.term_end.to_date

      while date <= last_day
        if TermDate.week(date) == params[:week].to_i && date.wday == params[:day].to_i
          @booking.date = date
          @message << "<li>" + I18n.t('booking.auto_book.made', :time => "#{date.strftime('%d/%m/%Y')}") + "</li>"
          @booking.save
        end

        date = date.tomorrow
      end

      @message << "</ul>"
      @message.html_safe
    end
  end
end

