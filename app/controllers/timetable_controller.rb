class TimetableController < ApplicationController
  def index

  end

  def show
    @date = params['date-select'].to_date
    until @date.monday?
      @date = @date.yesterday
    end

    @bookings = Booking.where(:room_id => params['room'])
    @room = Room.find(params['room']).name

    @bookings_for_table = []

    5.times do |i|
      @bookings_for_table << @bookings.where(:date => @date)
      @date = @date.tomorrow
    end

    respond_to do |format|
      format.js
    end
  end
end

