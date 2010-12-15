class BookingsController < ApplicationController
  before_filter :auth1

  def index
    @booking = Booking.new
  end

  def search
    @results = []

    Room.all.each do |room|
      result = {}

      noc_remaining = room.number_of_computers
      room.bookings.where(:date => params['booking']['date'].to_date, :lesson_number => params['booking']['lesson_number'].to_i).each do |booking|
        noc_remaining -= booking.number_of_computers
      end

      if noc_remaining >= params['booking']['number_of_computers'].to_i
        result[:room] = room.name
        result[:places] = noc_remaining

        result[:room_id] = room.id
        result[:date] = params['booking']['date']

        result[:number_of_computers] = params['booking']['number_of_computers']
        result[:lesson_number] = params['booking']['lesson_number']

        @results << result
      end
    end
  end

  def book
    @booking = Booking.new

    puts params

    @booking.room = Room.find(params[:room].to_i)
    @booking.user = User.find(session[:user_id])
    @booking.date = params[:date].to_date
    @booking.number_of_computers = params[:number_of_computers].to_i
    @booking.lesson_number = params[:lesson_number].to_i

    if @booking.save
      flash[:notice] = "booking.book.success"
    else
      flash[:notice] = "booking.book.not_success"
    end

    redirect_to :action => 'index'
  end

  def my_bookings
    @bookings = Booking.where(:user_id => session[:user_id]).where('date >= ?', Date.today).order('date ASC, lesson_number ASC')
  end

  def delete
    @booking = Booking.find(params[:id])
    if @booking.destroy
      flash[:notice] = "booking.delete.deleted"
    else
      flash[:notice] = "booking.delete.fail"
    end

    redirect_to :controller => 'bookings', :action => 'my_bookings'
  end
end

