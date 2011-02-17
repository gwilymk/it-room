class TimetableController < ApplicationController
  def index

  end

  def show
    @printer_friendly = params[:printer_friendly]

    @date = format_date(params['date-select']).to_date

    @date = @date.yesterday until @date.monday?

    @bookings = Booking.where(:room_id => params['room'])
    @room = Room.find(params['room']).name

    @bookings_for_table = []

    5.times do |i|
      @bookings_for_table << @bookings.where(:date => @date)
      @date = @date.tomorrow
    end

    @week = TermDate.week @date

    if @printer_friendly
      render "show", :layout => false
    end
  end
end

